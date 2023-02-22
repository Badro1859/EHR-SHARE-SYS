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
    }
    patient[] patients;

    modifier isAccount() {
        (uint index, bool exist) = authority.checkHealthAuthority(msg.sender);
        require(exist, "Caller have not permession");
        _;
    }

    constructor(address authorityAddress, address actorAddress){
        authority = HealthAuthority(authorityAddress);
        actor = HealthActor(actorAddress);

        patients.push(patient(20, 'badro', address(0xB09E8efD21A77Ee5FfDc5Aa3f70fcC22E3e060C6), new EHR()));
    }


    /**
    * ///////////////////////////////////////////////////////////////////////
    *         PUBLIC METHODS FOR REGISTRATION PURPOSE (Authority only)
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

    function addPatient(uint _id, string memory _name, address _account) public isAccount{
        (uint index, bool exist) = checkPatient(_id, _account);
        require(exist==false, "patient id or account already exist !!");

        patients.push(patient(_id, _name, _account, new EHR()));
    }

    function rmPatient(uint _id) public isAccount{
        (uint index, bool exist) = checkPatient(_id, address(0));
        require(exist==true, "patient does not exist !!");

        patients[index] = patients[patients.length-1];
        patients.pop();
    }


    /**
    * ///////////////////////////////////////////////////////////////////////
    *           PUBLIC METHODS FOR EHR PUBLISH PURPOSE (Patient only)
    * ///////////////////////////////////////////////////////////////////////
    */

    

    


    /**
    * ///////////////////////////////////////////////////////////////////////
    *                PUBLIC METHODS FOR REQUEST PURPOSE
    * ///////////////////////////////////////////////////////////////////////
    */

    function getNumberOfRequest() public view returns (uint256) {
        (uint index, bool exist) = checkPatient(0, msg.sender);
        require(exist, "You are not a patient !!");
        
        return patients[index].ehr.getNumberOfRequest();
    }

    function getRequestByIndex(uint256 _requestID) public view returns (uint, EHR.RequestType, bool){
        (uint index, bool exist) = checkPatient(0, msg.sender);
        require(exist, "You are not a patient !!");
        
        return patients[index].ehr.getRequestByIndex(_requestID);
    }

    /** 
     * @dev Create a new request from an actor.
     * @param _patientID this is a patient id
     * @param _requestType the type of request CONSULT PUBLISH
     */
    function sendRequest(uint _patientID, EHR.RequestType _requestType) public returns (uint){
        // check if caller is actor
        uint actorID = actor.getActorID(msg.sender);

        // check if patient exist 
        (uint index, bool exist) = checkPatient(_patientID, address(0));
        require(exist, "Patient does not exist !!");

        patients[index].ehr.setRequest(actorID,  _requestType);

        // event to patient

        return 0; // return the requestID
    }

    /** 
     * @dev Response to a request from associated patient.
     * @param _requestID the request id 
     */
    function setResponse(uint _requestID) public {
        // check if this is trusted patient 
        (uint index, bool exist) = checkPatient(0, msg.sender);
        require(exist, "you are not a patient, permission denied !!");

        // response to request 
        patients[index].ehr.setResponse(_requestID);

        // event to actor 
    }


    /**
    * ///////////////////////////////////////////////////////////////////////
    *                    PUBLIC METHODS FOR EHR PURPOSE
    * ///////////////////////////////////////////////////////////////////////
    */

    ////////////////////// FOR OWNER (patient)

    function getNbOfEHRByOwner() public view returns (uint256) {
        (uint index, bool exist) = checkPatient(0, msg.sender);
        require(exist, "You are not a Patient !!");

        return patients[index].ehr.ehrCount();
    }

    function getEHRbyOwner(uint _ehrID) view public returns (uint, string memory, string memory, string memory) {
        (uint index, bool exist) = checkPatient(0, msg.sender);
        require(exist, "You are not a Patient !!");

        EHR.EHRAbstract memory temp = patients[index].ehr.getEHRAbstract(_ehrID);
        
        return (temp.actorID, temp.ehrHash, temp.ipfsHashAddress, temp.secretKey);
    }

    ////////////////////// FOR REQUEST (actor)

    function shareEHR(uint _patientID, uint _requestID, string memory _hash, string memory _ipfsAddr, string memory _secretKey ) public {
        // check if patient exist 
        (uint index, bool exist) = checkPatient(_patientID, address(0));
        require(exist, "patient does not exist !!");

        // check if actor exist and get the actor id
        uint actorID = actor.getActorID(msg.sender);
       
        patients[index].ehr.addEHRAbstract(_requestID, actorID, _hash, _ipfsAddr, _secretKey);
    }

    function getNbOfEHRByActor(uint _patientID) public view returns (uint) {
        (uint index, bool exist) = checkPatient(_patientID, address(0));
        require(exist, "Patient Does Not Exist!!");

        return patients[index].ehr.ehrCount();
    }

    function getEHRbyActor(uint _patientID, uint _requestID, uint _ehrID) view public returns (uint, string memory, string memory, string memory) {
        // check if patient exist 
        (uint index, bool exist) = checkPatient(_patientID, address(0));
        require(exist, "patient does not exist !!");

        // check if actor exist and get the actor id
        uint actorID = actor.getActorID(msg.sender);

        EHR.EHRAbstract memory temp = patients[index].ehr.getEHRbyActor(_requestID, actorID, _ehrID);

        return (temp.actorID, temp.ehrHash, temp.ipfsHashAddress, temp.secretKey);
    }   


}
