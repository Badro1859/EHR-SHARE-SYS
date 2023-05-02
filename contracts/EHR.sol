// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

/** 
 * @title EHR
 * @dev Implements EHR methods
 */
contract EHR {
    // request expired time in second
    uint256 constant EXPIRED_TIME = 86400;

    enum RequestType {
        PUBLISH,
        CONSULT
    }
    enum RequestState {
        ACCEPTED,
        REFUSED,
        PENDING,
        CANCELLED
    }
    struct request {
        uint actorID;
        uint256 timestamp;
        RequestType rType;
        RequestState state;        
    }
    request[] requests;

    enum EHRType {
        examen,
        SCANNER
    }
    struct EHRAbstract {
        // uint id; index in the array of EHRAbstract
        string title;
        uint256 date;
        uint actorID;
        string ehrHash;
        string ipfsHashAddress;
        string secretKey;
    }
    // EHRAbstract[] ehrArray;
    mapping(uint256 => EHRAbstract) public ehrArray;
    uint256 public ehrCount = 0;

    
    constructor () {
        ehrCount++;
        ehrArray[ehrCount] = EHRAbstract("test_title", block.timestamp, 23, "test", "Hello world", "test");

        requests.push(request(23, block.timestamp, RequestType.CONSULT, RequestState.PENDING));
        // requests.push(request(25, block.timestamp, RequestType.CONSULT, RequestState.ACCEPTED));
    }


    /**
    * /////////////////////////////////////////////////////////
    *           PUBLIC METHODS FOR REQUEST PURPOSE 
    * /////////////////////////////////////////////////////////
    */
    
    function checkExpiredRequests() internal {
        for (uint i=0; i<requests.length;i++) {
            if (requests[i].state == RequestState.PENDING) {
                uint256 currentTimestamp = block.timestamp;
                uint256 timeDifference = currentTimestamp - requests[i].timestamp;
                if (timeDifference > EXPIRED_TIME){
                    requests[i].state = RequestState.CANCELLED;
                }
            }
        }     
    }

    // #### for patient utilization ###
    function getNumberOfRequest() public view returns (uint) {
        // checkExpiredRequests();
        return requests.length;
    }

    function getRequestByIndex(uint _index) public view returns (uint, uint256, RequestType, RequestState) {
        require(_index >= 0 && _index < requests.length, "WRONG INDEX FOR REQUEST !!");
        return (requests[_index].actorID, requests[_index].timestamp, requests[_index].rType, requests[_index].state);
    }

    function setResponse(uint _requestID, RequestState _newState) public {
        (bool exist, ) = checkRequest(_requestID);
        require(exist, "Request does not exist !!");
        requests[_requestID].state = _newState;
    }

    // ### for actor utilization ###
    function setRequest(uint _actorID, RequestType _type) public returns (uint){
        uint index = requests.length;
        uint256 currentTimestamp = block.timestamp;
        requests.push(request(_actorID, currentTimestamp, _type, RequestState.PENDING));
        return index;
    }

    function checkResponse(uint _actorID, RequestType _type) public view returns (RequestState, uint) {
        uint256 currentTimestamp = block.timestamp;
        uint i = requests.length;
        for (i; i>0; i--) {
            if (requests[i-1].actorID == _actorID && requests[i-1].rType == _type) {
                uint256 timeDifference = currentTimestamp - requests[i-1].timestamp;
                if (timeDifference > EXPIRED_TIME){ // CANCELLED
                    return (RequestState.CANCELLED, 0);
                } else {
                    return (requests[i-1].state, i-1);
                }
            }
        }
        return (RequestState.PENDING, 0);
    }

    // ### for internal utilization ###
    function checkRequest(uint _requestID) view public returns (bool, bool) {
        uint256 currentTimestamp = block.timestamp;
        uint256 timeDifference = currentTimestamp - requests[_requestID].timestamp;
                
        if (timeDifference > EXPIRED_TIME){ // CANCELLED
            return (false, false);
        }
        if (requests[_requestID].state == RequestState.ACCEPTED) {
            return (true, true); 
        }
        return (true, false); // REFUSED OR PENDING
    }

    


    /**
    * /////////////////////////////////////////////////////////
    *           PUBLIC METHODS FOR EHR PURPOSE 
    * /////////////////////////////////////////////////////////
    */

    ////////////////////// FOR OWNER
    function getEHRAbstract(uint _ehrID) view public returns (EHRAbstract memory) {
        require(_ehrID > 0 && _ehrID <= ehrCount, "EHR does not exist !!");
        return ehrArray[_ehrID];
    } 

    ////////////////////// FOR ACTOR
    function addEHRAbstract(uint _requestID, string memory _title, uint _actorID, string memory _hash, string memory _ipfsAddr, string memory _secretKey) public returns (uint _ehrID) {

        // 1 - check the request 
        (bool exist, bool accepted) = checkRequest(_requestID);
        require(exist && accepted, "Request does not exist or does not accepted !!");

        // 2 - check if actor is the same in the request 
        require(requests[_requestID].actorID == _actorID, "permission denied !!");

        // 3 - check the type of request (publish)
        require(requests[_requestID].rType == RequestType.PUBLISH, "permission denied !!");


        // share the EHR
        ehrCount++;
        ehrArray[ehrCount] = EHRAbstract(_title, block.timestamp, _actorID, _hash, _ipfsAddr, _secretKey);

        return ehrCount;
    }

    function getEHRbyActor(uint _requestID, uint _actorID, uint _ehrID) view public returns (EHRAbstract memory) {
        // 1 - check the request 
        (bool exist, bool accepted) = checkRequest(_requestID);
        require(exist && accepted, "Request does not exist or does not accepted !!");

        // 2 - check if the same actor 
        require(requests[_requestID].actorID == _actorID, "permission denied !!");

        // 3 - check the type of request (consult)
        require(requests[_requestID].rType == RequestType.CONSULT, "permission denied !!");

        return getEHRAbstract(_ehrID);
    }
}