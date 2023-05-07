// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import {EHR} from "./EHR.sol";
import {HealthAuthority} from "./HealthAuthority.sol";
import {HealthActor} from "./HealthActor.sol";


/** 
 * @title Patient
 * @dev Implements Patient methods
 */
contract Patient {

    HealthAuthority authority;
    HealthActor actor;

    struct patient{
        uint id;
        string name;
        address addr;
        EHR ehr;
        string public_key;
    }
    patient[] patients;

    modifier onlyAuthority() {
        (uint index, bool exist) = authority.checkHealthAuthority(msg.sender);
        require(exist, "Caller have not permession");
        _;
    }

    constructor(address authorityAddress, address actorAddress){
        authority = HealthAuthority(authorityAddress);
        actor = HealthActor(actorAddress);

        // patients.push(patient(20, 'badro', address(0x87C8Ea2F6EF914766609df6C776e65b191F97EF8), new EHR(), "public_key"));
        // patients.push(patient(25, 'bilal', address(0xDb4454a0Ff6c7eBeAD241de2432D68648f4b2ff5), new EHR(), "public_key"));
    }

    /**
    * ///////////////////////////////////////////////////////////////////////
    *                       PUBLIC METHODS FOR PATIENT (GETTERS)
    * ///////////////////////////////////////////////////////////////////////
    */
    function checkPatient(uint _id, address _address) view public returns (uint, bool) {
        uint index = 0;
        bool exist = false;
        for (uint i = 0; i < patients.length ; i++){
            if (patients[i].id == _id || patients[i].addr == _address){
                exist = true;
                index = i;
                break;
            }
        }
        return (index, exist);
    }

    function getNumberOfPatient() public view returns(uint) {
        return patients.length;
    }

    function getPatientByIndex(uint _index) public view returns(uint, string memory, address) {
        require(_index >= 0 && _index < patients.length, "Wrong index!!");
        return (patients[_index].id, patients[_index].name, patients[_index].addr);
    }

    /**
    * ///////////////////////////////////////////////////////////////////////
    *                       PUBLIC METHODS FOR REQEUST
    * ///////////////////////////////////////////////////////////////////////
    */
    ////////// ONLY CALL BY PATIENT //////////
    function getNumberOfRequest() public view returns (uint256) {
        (uint index, bool exist) = checkPatient(0, msg.sender);
        require(exist, "You are not a patient !!");
        return patients[index].ehr.getNumberOfRequest();
    }
    function getRequestByIndex(uint256 _requestID) public view returns (string memory, uint256, EHR.RequestType, EHR.RequestState, string memory){
        (uint index, bool exist) = checkPatient(0, msg.sender);
        require(exist, "You are not a patient !!");
        // get a request : (actorID, timestamp, rType, state)
        (uint actorID, uint256 timestamp, EHR.RequestType rType, EHR.RequestState state) = patients[index].ehr.getRequestByIndex(_requestID);

        (string memory actorName, string memory centerName) = actor.getActorAndCenterName(actorID);

        return (actorName, timestamp, rType, state, centerName);
    }
    /** 
     * @dev Response to a request from associated patient.
     * @param _requestID the request id 
     */
    function setResponse(uint _requestID, EHR.RequestState _newState) public {
        // check if this is trusted patient 
        (uint index, bool exist) = checkPatient(0, msg.sender);
        require(exist, "you are not a patient, permission denied !!");

        // response to request 
        patients[index].ehr.setResponse(_requestID, _newState);

        // event to actor 
    }

    ////////// ONLY CALL BY ACTOR //////////
    function verifyAuthorization(uint _patientID, EHR.RequestType _type) public view returns (EHR.RequestState, uint) {
        (uint index, bool exist) = checkPatient(_patientID, address(0x0));
        require(exist, "This patient does not exist !! ");
        // get actor id for checking respose
        uint actor_id = actor.getActor(msg.sender).id;
        return patients[index].ehr.checkResponse(actor_id, _type);
    }
    /** 
     * @dev Create a new request from an actor.
     * @param _patientID this is a patient id
     * @param _requestType the type of request CONSULT PUBLISH
     */
    function sendRequest(uint _patientID, EHR.RequestType _requestType) public returns (bool){
        // check if caller is actor
        uint actorID = actor.getActor(msg.sender).id;

        // check if patient exist 
        (uint index, bool exist) = checkPatient(_patientID, address(0));
        require(exist, "Patient does not exist !!");

        patients[index].ehr.setRequest(actorID,  _requestType);

        //TODO: event to patient

        return true; // return the requestID
    }


    /**
    * ///////////////////////////////////////////////////////////////////////
    *                    PUBLIC METHODS FOR EHR PURPOSE
    * ///////////////////////////////////////////////////////////////////////
    */
    
    function getNbOfEHR(uint _patientID) public view returns (uint256) {
        (uint index, bool exist) = checkPatient(_patientID, msg.sender);
        require(exist, "This patient does not exist !!");
        return patients[index].ehr.ehrCount();
    }

    //test 
    function getEHR(uint _ehrID, uint _patientID) view public returns (string memory, uint256,string memory,string memory, string memory, string memory, string memory) {    
        // EHR = (title, date, actorName, centerName, hash, ipfs, secretKey)  

        //// if the caller is patient
        (uint index, bool isPatient) = checkPatient(0, msg.sender);
        if (isPatient) {
            EHR.EHRAbstract memory temp1 = patients[index].ehr.getEHRAbstract(_ehrID);
            (string memory actorName, string memory centerName) = actor.getActorAndCenterName(temp1.actorID);
            return (temp1.title, temp1.date , actorName, centerName, temp1.ehrHash, temp1.ipfsHashAddress, temp1.secretKey);
        }

        //// if the caller is actor => 
        // check if patient exist 
        (index, isPatient) = checkPatient(_patientID, address(0));
        require(isPatient, "patient does not exist !!");
        // check actor
        uint actorID = actor.getActor(msg.sender).id;
        // check the authorization
        (EHR.RequestState state, uint _requestID) = patients[index].ehr.checkResponse(actorID, EHR.RequestType.CONSULT);
        require(state==EHR.RequestState.ACCEPTED, "Permission denied !! please request patient for consulting...");
        // get the EHR
        EHR.EHRAbstract memory temp = patients[index].ehr.getEHRbyActor(_requestID, actorID, _ehrID);
        (string memory actorrName, string memory centerrName) = actor.getActorAndCenterName(temp.actorID);
        return (temp.title, temp.date , actorrName, centerrName, temp.ehrHash, temp.ipfsHashAddress, temp.secretKey);
    }

    /////////////// ACTOR ONLY ///////////////

    function shareEHR(uint _patientID, uint _requestID, string memory _title, string memory _hash, string memory _ipfsAddr, string memory _secretKey ) public {
        // check if patient exist 
        (uint index, bool exist) = checkPatient(_patientID, address(0));
        require(exist, "patient does not exist !!");

        // check if actor exist and get the actor id
        uint actorID = actor.getActor(msg.sender).id;
       
        patients[index].ehr.addEHRAbstract(_requestID, _title, actorID, _hash, _ipfsAddr, _secretKey);
    }



    /**
    * ///////////////////////////////////////////////////////////////////////
    *         PUBLIC METHODS FOR REGISTRATION PURPOSE (Authority only)
    * ///////////////////////////////////////////////////////////////////////
    */
    function addPatient(uint _id, string memory _name, address _account, string memory _pKey) public onlyAuthority {
        (, bool exist) = checkPatient(_id, _account);
        require(exist==false, "patient id or account already exist !!");

        patients.push(patient(_id, _name, _account, new EHR(), _pKey));
    }

    function rmPatient(uint _id) public onlyAuthority{
        (uint index, bool exist) = checkPatient(_id, address(0));
        require(exist==true, "patient does not exist !!");

        patients[index] = patients[patients.length-1];
        patients.pop();
    }
}
