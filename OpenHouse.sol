// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <0.9.0;
pragma abicoder v2;

/**
 * @title OpenHouse
 * @dev Create, join, and interact with OpenHouse-enabled rooms
 */
contract OpenHouse {

    string[] private rooms;
    
    mapping (string => bool) private _roomsMap;
    
    mapping (string => address[]) private _memberships;
    
    mapping (string => mapping (address => bool)) private _membershipsMap;
    
    mapping (address => string[]) private _userToRoomsMap;
    
    mapping (string => bool) private _roomPrivacyMap;
    
    function addUserToRoom(string calldata name, address user) private {
        if (!_membershipsMap[name][user]){
            _membershipsMap[name][user] = true;
            _memberships[name].push(user);
            _userToRoomsMap[user].push(name);
        }
    }

    /**
     * @dev Create a room, or join it if it already exists.
     * @param name defines the room
     */
    function addRoom(string calldata name) public {
        if (!_roomsMap[name]){
            _roomsMap[name] = true;
            rooms.push(name);
        }
        addUserToRoom(name, msg.sender);
    }
    
    /**
     * @dev Add the specified list of members to a room, creating it if it doesn't exist.
     * @param name of the room
     * @param members to add to the room
     */
    function addRoomWithMembers(string calldata name, address[] calldata members) public {
        addRoom(name);
        for (uint i = 0; i < members.length; i++) {
            address member = members[i];
            addUserToRoom(name, member);
        }
    }
    
    /**
     * @dev List all rooms that have already been created.
     */
    function listRooms() public view returns (string[] memory) {
        return rooms;
    }
    
    /**
     * @dev List the rooms for which the caller is a member.
     */
    function listMyRooms() public view returns (string[] memory) {
        return _userToRoomsMap[msg.sender];
    }
    
    /**
     * @dev Return the status of a caller's membership in the given room
     * @param name of the room
     */
    function isMember(string calldata name) public view returns (bool) {
        return _membershipsMap[name][msg.sender];
    }
    
    /**
     * @dev Make the requested room private if the user is a member.
     * @param name of the room to make private.
     */
    function makeRoomPrivate(string calldata name) public {
        if (_membershipsMap[name][msg.sender]) {
            _roomPrivacyMap[name] = true;
        }
    }
    
    /**
     * @dev Make the requested room open if the user is a member.
     * @param name of the room to make open.
     */
    function makeRoomOpen(string calldata name) public {
        if (_membershipsMap[name][msg.sender]) {
            _roomPrivacyMap[name] = false;
        }
    }
}