import ballerina/http;
import ballerina/file;
import ballerina/mime;
import ballerina/log;
import ballerina/regex;

type User record {
    string user;
    string gender;
    string role;
    string status;
};

// file extension mapping to content types
final map<string> MIME_MAP = {
    "json": mime:APPLICATION_JSON,
    "xml": mime:TEXT_XML,
    balo: mime:APPLICATION_OCTET_STREAM,
    css: "text/css",
    gif: "image/gif",
    html: mime:TEXT_HTML,
    ico: "image/x-icon",
    jpeg: "image/jpeg",
    jpg: "image/jpeg",
    js: "application/javascript",
    png: "image/png",
    svg: "image/svg+xml",
    txt: mime:TEXT_PLAIN,
    woff2: "font/woff2",
    zip: "application/zip"
};

service / on new http:Listener(9090) {

    resource function 'default [string... paths](http:Caller caller, http:Request req) returns error? {

        http:Response res = new;
        string requestedFilePath = req.extraPathInfo;

        if (requestedFilePath.equalsIgnoreCaseAscii("//")) {
            requestedFilePath = "index.html";
        }

        string path = check file:joinPath("../public/", requestedFilePath);
        res = getFileAsResponse(path);

        error? clientResponse = caller->respond(res);
        if (clientResponse is error) {
            log:printError("Unable respond back", 'error = clientResponse);
            return error("Error while responding back");
        }
    }

    resource function get users() returns User[] {

        User user1 = {user: "John Doe", role: "Admin", gender: "Male", status: "Active"};
        User user2 = {user: "Jane Smith", role: "User", gender: "Female", status: "Inactive"};
        User user3 = {user: "Alex Ben", role: "User", gender: "Male", status: "Active"};
        User user4 = {user: "Sarah Davis", role: "Admin", gender: "Female", status: "Active"};

        User[] users = [user1, user2, user3, user4];
        return users;
    }
}

# Serve a file as a http response.
#
# + requestedFile - The path of the file to server.
# + return - The http response.
function getFileAsResponse(string requestedFile) returns http:Response {

    http:Response res = new;
    string contentType = mime:APPLICATION_OCTET_STREAM;
    string fileExtension = getExtension(requestedFile);

    if (fileExtension != "") {
        contentType = getMimeTypeByExtension(fileExtension);
    }

    boolean fileExists;
    do {
        fileExists = check file:test(requestedFile, file:EXISTS);
    } on fail var e {
        log:printError("Error while checking file existence", 'error = e);
        fileExists = false;
    }

    if (fileExists) {
        res.setFileAsPayload(requestedFile, contentType = contentType);
    } else {
        log:printError("Unable to find the file: " + requestedFile);
        res.setTextPayload("The server was not able to find what you were looking for.");
        res.statusCode = http:STATUS_NOT_FOUND;
    }
    return res;
}

# Get the content type using a file extension.
#
# + extension - The file extension.
# + return - The content type if a match is found, else application/octet-stream.
function getMimeTypeByExtension(string extension) returns string {
    var contentType = MIME_MAP[extension.toLowerAscii()];
    if (contentType is string) {
        return contentType;
    } else {
        return mime:APPLICATION_OCTET_STREAM;
    }
}

function getExtension(string filePath) returns string {

    string[] result = regex:split(filePath, "\\.");

    if result.length() > 1 {
        return result[result.length() - 1];
    }
    return "";
}
