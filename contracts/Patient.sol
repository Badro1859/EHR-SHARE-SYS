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
     * @dev Response to a request from associated patient.
     * @param _requestID the request id 
     */
    // function AuthorizationResponse(uint _requestID, bool _response) public {
    //     // check if this is trusted patient 
    //     (uint index, bool exist) = checkPatient(0, msg.sender);
    //     require(exist, "you are not a patient, permission denied !!");

    //     // response to request 
    //     patients[index].ehr.setResponse(_requestID, _response);

    //     // event to actor
    // }

    // function getEHRbyOwner(uint _ehrID, bool _lastOne) view public returns (EHR.EHRAbstract memory, uint){
    //     (uint index, bool exist) = checkPatient(0, msg.sender);
    //     require(exist, "patient does not exist !!");

    //     if (_lastOne) {
    //         return patients[index].ehr.getLastEHR();
    //     }
    //     else {
    //         return (patients[index].ehr.getEHRAbstract(_ehrID), _ehrID);
    //     }
    // }


    /**
    * ///////////////////////////////////////////////////////////////////////
    *           PUBLIC METHODS FOR EHR PUBLISH PURPOSE (Actor only)
    * ///////////////////////////////////////////////////////////////////////
    */

    /** 
     * @dev Create a new request from an actor.
     * @param _patientID and the request type and ehrID
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

    // function shareEHR(uint _patientID, uint _requestID, string memory _hash, string memory _ipfsAddr, string memory _secretKey ) public returns (uint) {
    //     // check if patient exist 
    //     (uint index, bool exist) = checkPatient(_patientID, address(0));
    //     require(exist, "patient does not exist !!");

    //     // check if actor exist and get the actor id
    //     uint actorID = actor.getActorID(msg.sender);
       
    //     return patients[index].ehr.addEHRAbstract(_requestID, actorID, EHR.EHRType.SCANNER, _hash, _ipfsAddr, _secretKey);
    // }   

    // function getEHRbyRequest(uint _patientID, uint _requestID) view public returns (EHR.EHRAbstract memory ehr) {
    //     // check if patient exist 
    //     (uint index, bool exist) = checkPatient(_patientID, address(0));
    //     require(exist, "patient does not exist !!");

    //     // check if actor exist and get the actor id
    //     uint actorID = actor.getActorID(msg.sender);

    //     return patients[index].ehr.getEHRbyActor(_requestID, actorID);
    // }   

}
