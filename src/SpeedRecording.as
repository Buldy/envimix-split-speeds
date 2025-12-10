class SpeedRecording {

    float[]@ cps = { };
    uint lastCpTime = 0; // Only used for unfinished runs and not written to file
    uint time = 0;
    string variation = "";
    bool isOnline = false;

    Json::Value LoadRootOrNew(const string &in path) {
        // No file yet, will create a new object instead
        if (!IO::FileExists(path)) {
            auto root = Json::Object();
            root["version"] = 3;
            print("File for this map doesn't exist: " + path);
            return root;
        }

        // Load file if it exists
        try {
            auto root = Json::FromFile(path);
            if (root.GetType() != Json::Type::Object) {
               print("Root JSON in " + path + " is not an object, resetting.");
               root = Json::Object();
            }
            return root;
            
        } catch {
            print("Failed to load JSON from " + path + ", starting fresh");
            auto root = Json::Object();
            root["version"] = 3;
            return root;
        }
    }

    void ToFile(const string&in path, const string &in mapName) {
        print("ToFile! time: " + time + ", " + path);

        Json::Value root = LoadRootOrNew(path);
        print("Tried to load old records: " + Json::Write(root));
        Json::Value speeds = Json::Object();

        speeds["time"] = time;
        speeds["isOnline"] = isOnline;

        speeds["cps"] = Json::Array();
        for (uint i = 0; i < cps.Length; i++) {
            speeds["cps"].Add(cps[i]);
        }

        root[mapName] = speeds;
        Json::ToFile(path, root, true);
    }

    string ToString() {
        string[] cpsStr = { };
        for (uint i = 0; i < cps.Length; i++) {
            cpsStr.InsertLast(tostring(cps[i]));
        }
        return "SpeedRecording < time = " + Time::Format(time) + ", cps = { " + (string::Join(cpsStr, " / ")) + " } >";
    }

    void DrawDebugInfo() {
        string[] cpsStr = { };
        for (uint i = 0; i < cps.Length; i++) {
            cpsStr.InsertLast(tostring(cps[i]));
        }
        UI::TextWrapped("SpeedRecording < time = " + Time::Format(time) + ", cps = { " + (string::Join(cpsStr, " / ")) + " }" + ", lastCpTime = " + Time::Format(lastCpTime) + " >");
    }

}

namespace SpeedRecording {

    SpeedRecording@ FromFile(const string&in path, const string &in mapName) {
        if (!IO::FileExists(path)) return null;
        if (path == ".json") return null;
        auto json = Json::FromFile(path);
        if (json.GetType() != Json::Type::Object) return null;

        int version = json["version"].GetType() == Json::Type::Number ? json["version"] : 0;

#if MP4
        if (version < 3) {
            print("Old splits version on map found! Deleting splits for this map.");
            IO::Delete(path);
            return null;
        }
#elif TURBO
        auto playground = cast<CTrackManiaRaceNew>(GetApp().CurrentPlayground);
        auto playgroundScript = cast<CTrackManiaRaceRules>(GetApp().PlaygroundScript);
        if (version < 2 && playgroundScript.MapNbLaps > 1) {
            print("Old splits version on MultiLap map found! Deleting splits for this map.");
            IO::Delete(path);
            return null;
        }
#endif

        if (version == 0) {
            return Version0(json);
        } else if (version == 1) {
            return Version1(json);
        } else if (version == 2) {
            return Version2(json);
        } else if (version == 3) {
            return Version3(json, mapName);
        } else {
            warn("Unsupported recorded speeds json version: " + path);
        }

        return null;
    }

    SpeedRecording@ Version0(Json::Value json) {
        auto result = SpeedRecording();
        if (json['pb'].GetType() != Json::Type::Number) {
            warn("Speedsplits file V0 has invalid pb time!");
            return null;
        }
        result.time = json['pb'];
        result.isOnline = true;
        int i = 1;
        while (true) {
            auto val = json[tostring(i++)];
            if (val.GetType() == Json::Type::Number) {
                result.cps.InsertLast(val);
            } else {
                break;
            }
        }
        print("V0: Loaded splits from file, online: " + result.isOnline + ", time: " + result.time + ", cp count: " + result.cps.Length);
        return result;
    }

    SpeedRecording@ Version1(Json::Value json) {
        auto result = SpeedRecording();
        result.time = json["time"];
        result.isOnline = json["isOnline"];
        if (json['cps'].GetType() != Json::Type::Array) return null;
        for (uint i = 0; i < json['cps'].Length; i++) {
            result.cps.InsertLast(json['cps'][i]);
        }
        print("V1: Loaded splits from file, online: " + result.isOnline + ", time: " + result.time + ", cp count: " + result.cps.Length);
        return result;
    }

    SpeedRecording@ Version2(Json::Value json) {
        auto result = SpeedRecording();
        result.time = json["time"];
        result.isOnline = json["isOnline"];
        if (json['cps'].GetType() != Json::Type::Array) return null;
        for (uint i = 0; i < json['cps'].Length; i++) {
            result.cps.InsertLast(json['cps'][i]);
        }
        print("V2: Loaded splits from file, online: " + result.isOnline + ", time: " + result.time + ", cp count: " + result.cps.Length);
        return result;
    }

    SpeedRecording@ Version3(const Json::Value &in json, const string &in variation) {
        if (json[variation] !is null) {
            Json::Value branchJson = json[variation];
            auto result = SpeedRecording();
            result.variation = variation;
            result.time = branchJson["time"];
            result.isOnline = branchJson["isOnline"];
            if (branchJson['cps'].GetType() != Json::Type::Array) return null;
            for (uint i = 0; i < branchJson['cps'].Length; i++) {
                result.cps.InsertLast(branchJson['cps'][i]);
            }
            print("V3: Loaded splits from file, online: " + result.isOnline + ", time: " + result.time + ", cp count: " + result.cps.Length + ", Car Variation: " + result.variation);
            return result;
        } else {
            auto result = SpeedRecording();
            result.variation = variation;
            result.time = 2147483647;
            result.isOnline = false;
            result.cps = { };
            print("No splits found in file.");
            return result;
        }
    }

}
