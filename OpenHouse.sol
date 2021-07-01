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
    mapping (string => bool) private _roomsPublic;
    
    mapping (string => address[]) private _memberships;
    mapping (address => string[]) private _reverseMemberships;
    
    mapping (string => mapping (address => bool)) private _membershipsMap;

    mapping (string => mapping ( address => address[])) private _kickRequestsMap;

    /**
     * @dev Create a room, or join it if it already exists.
     * @param name defines the room
     */
    function addRoom(string calldata name, bool isPublic) public {
        if (!_roomsMap[name]){
            _roomsMap[name] = true;
            _roomsPublic[name] = isPublic;
            rooms.push(name);
        }
        
        address sender = msg.sender;
        if (!_membershipsMap[name][sender]) {
            _membershipsMap[name][sender] = true;
            _memberships[name].push(sender);
            _reverseMemberships[sender].push(name);
        }
    }
    
    /**
     * @dev List all rooms that have already been created.
     */
    function listRooms() public view returns (string[] memory) {
        return rooms;
    }
    
    /**
     * @dev List all rooms for which the sender has membership
     */
    function listSenderRooms() public view returns (string[] memory) {
        address sender = msg.sender;
        return _reverseMemberships[sender];
    }
    
    /**
     * @dev Check if the sender is a member of the given room
     * @param name specifies the room to check membership for
     */
    function senderIsInRoom(string calldata name) public view returns (bool) {
        address sender = msg.sender;
        return _membershipsMap[name][sender];
    }
    
    /**
     * @dev Check if a room exists
     */
    function roomExists(string calldata name) public view returns (bool) {
        return _roomsMap[name];
    }
    
    /**
     * @dev Check if a room is public
     */
    function roomIsPublic(string calldata name) public view returns (bool) {
        return _roomsPublic[name];
    }
    
    /**
     * @dev Return the list of addresses that belong to a room.
     * @param name specifies the room to list memberships for.
     */
    function members(string calldata name) public view returns (address[] memory) {
        return _memberships[name];
    }

        /**
     * @dev Register the sender's request to kick a user from a room, removing
     * the user if enough members have requested the user's removal.
     * @param user to be kicked
     * @param room from which to kick the user
     */
    function kickUser(address user, string memory room) public {
        uint length = _kickRequestsMap[room][user].length;
        for (uint i = 0; i < length; i++) {
            if (_kickRequestsMap[room][user][i] == msg.sender) {
                return;
            }
        }
        _kickRequestsMap[room][user].push(msg.sender);
        if (_kickRequestsMap[room][user].length > 1) {
            removeUserFromRoom(user, room);
        }
    }

    /**
    * @dev Remove a user from a room.
    * @param user to be removed
    * @param room from which to remove the user
    */
     function removeUserFromRoom(address user, string memory room) private {
        if (_membershipsMap[room][user]) {
            // Remove user from the memberships list
            uint length = _memberships[room].length;
            for (uint i=0; i < length; i++) {
                if (_memberships[room][i] == user) {
                    _memberships[room][i] = _memberships[room][length - 1];
                    _memberships[room].pop();
                    break;
                }
            }
            
            // Remove room from the user's list of rooms
            length = _reverseMemberships[user].length;
            for (uint i = 0; i < length; i++) {
                if (keccak256(abi.encodePacked(_reverseMemberships[user][i])) == keccak256(abi.encodePacked(room))) {
                    _reverseMemberships[user][i] = _reverseMemberships[user][length - 1];
                    _reverseMemberships[user].pop();
                    break;
                }
            }
            
            // Remove user->room combination from _membershipsMap
            _membershipsMap[room][user] = false;
        }
    }
}