// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

/** 
 * @title EHR
 * @dev Implements EHR methods
 */
contract EHR {

    enum RequestType {
        PUBLISH,
        CONSULT
    }

    struct request {
        // uint id; index in the array of request
        uint actorID;
        // uint ehrID;
        RequestType rType;
        bool accepted;
        uint ReadyTime;
    }
    request[] requests;

    enum EHRType {
        examen,
        SCANNER
    }

    struct EHRAbstract {
        // uint id; index in the array of EHRAbstract
        uint actorID;
        EHRType eType;
        string hash;
        string ipfsHashAddress;
        string secretKey;
        // uint date; // TODO
    }
    EHRAbstract[] ehrArray;

    


    /**
    * /////////////////////////////////////////////////////////
    *           PUBLIC METHODS FOR REQUEST PURPOSE 
    * /////////////////////////////////////////////////////////
    */
    function getNumberOfRequest() public view returns (uint) {
        return requests.length;
    }

    function getRequestByIndex(uint _index) public view returns (uint, RequestType, bool) {
        require(_index >= 0 && _index < requests.length, "WRONG INDEX FOR REQUEST !!");
        return (requests[_index].actorID, requests[_index].rType, requests[_index].accepted);
    }

    function setRequest(uint _actorID, RequestType _type) public returns (uint){
        uint index = requests.length;
        bool accepted = false;

        requests.push(request(_actorID,  _type, accepted, 0));

        return index;
    }

    function checkRequest(uint _requestID) view public returns (bool, bool) {
        bool exist = false;
        bool accepted = false;
        if (requests.length > _requestID) {
            exist = true;
            accepted = requests[_requestID].accepted;
        }

        return (exist, accepted);
    }

    function setResponse(uint _requestID, bool response) public {
        (bool exist, bool accepted) = checkRequest(_requestID);
        require(exist, "Request does not exist !!");

        requests[_requestID].accepted = true;
        // TODO: readyTime
    }


    /**
    * /////////////////////////////////////////////////////////
    *           PUBLIC METHODS FOR EHR PURPOSE 
    * /////////////////////////////////////////////////////////
    */

    // function addEHRAbstract(uint _requestID, uint _actorID, EHRType _type, string memory _hash, string memory _ipfsAddr, string memory _secretKey ) public returns (uint _ehrID) {

    //     // 1 - check the request 
    //     (bool exist, bool accepted) = checkRequest(_requestID);
    //     require(exist && accepted, "Request does not exist or does not accepted !!");

    //     // 2 - check if actor is the same in the request 
    //     require(requests[_requestID].actorID == _actorID, "permission denied !!");

    //     // 3 - check the type of request (publish)
    //     require(requests[_requestID].rType == RequestType.PUBLISH, "permission denied !!");


    //     // share the EHR
    //     _ehrID = ehrArray.length;
    //     ehrArray.push(EHRAbstract(_actorID, _type, _hash, _ipfsAddr, _secretKey));

    //     return _ehrID;
    // }

    // function checkEHR(uint _ehrID) view public returns (bool) {
    //     if (ehrArray.length > _ehrID){
    //         return true;
    //     }
    //     return false;
    // }

    // function getEHRAbstract(uint _ehrID) view public returns (EHRAbstract memory) {
    //     require(checkEHR(_ehrID), "EHR does not exist !!");

    //     return ehrArray[_ehrID];
    // } 

    // function getLastEHR() view public returns (EHRAbstract memory, uint _ehrID) {
    //     require(ehrArray.length > 0, "not exist any EHR !!");

    //     _ehrID = ehrArray.length -1;
    //     return (ehrArray[_ehrID], _ehrID);
    // }

    // function getEHRbyActor(uint _requestID, uint _actorID) view public returns (EHRAbstract memory) {
    //     // 1 - check the request 
    //     (bool exist, bool accepted) = checkRequest(_requestID);
    //     require(exist && accepted, "Request does not exist or does not accepted !!");

    //     // 2 - check if the same actor 
    //     require(requests[_requestID].actorID == _actorID, "permission denied !!");

    //     return ehrArray[requests[_requestID].ehrID];
    // }
    
}