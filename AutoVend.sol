pragma solidity ^0.4.17;
import "StringUtils";

/* AutoVend
 * contract for physical vending machine 
 * _creator   = contract owner
 * _inventory = inventory
 */
contract AutoVend {
    // automated vending machine contract
    address  _creator;
    address  _coinStorage;
    bool     _testMode;
    bool     _running;
    uint32   _stgIdx;
    uint8    STORAGE_MAX = 6;
    
    struct Item {
      string  name;
      uint256 cost;
      uint32  cnt;        
      address supplier;
      function(address) external resupply; //NOTE: not possible?
    }
    
    struct store { //NOTE: This doesn't corrently allow for a store[] to hold items. See inventory note.
      Item item; //NOTE: hella poor naming convention
      bool locked;
      bool isActive;
    }
    
    struct inventory { 
      // NOTE: item[6] instead of stor
      store[6] strg; //NOTE: storage is a key word!
      mapping(address => Item) resupplyAddress;
    }
    
    inventory _inv;
    
    function AutoVend(uint8 itemCnt,
                      uint256 balance,
                      bool testMode) 
    {
      _coinStorage = address(balance);
      _creator  = msg.sender; 
      _testMode = testMode; //made bool, should be bool?
      _stgIdx   = 0;
      // connect the vending machine to le blockchainz
      // this.goLive();
      _running  = true;
    }
    
    function _addItem(Item _item) internal {
      if (_stgIdx < 4) { // if we are not at max items
        bool success = false;
        for (uint32 i = 0; i < STORAGE_MAX; i++) {
          if(!_inv.strg[i].isActive) {
            _inv.strg[i].isActive  = true;
            _inv.strg[i].item      = _item;
            success                = true;
          } 
        }
        // if failed to add to array
        if(!success) {
          // shit be fucked, u no add:: maybe resize array
          // TODO: !!!! refund user !!!
          revert();
        }
      } 
    }
    // NOTE: For unlock, lock, and remove we take in a storeIdx as uint8,
    //       but pass them items in use. 
    function _unlock_store(uint32 storeIdx) internal {
      // make api call to physical device
      _inv.strg[storeIdx].locked = false;
      // currently dysfunctional while store struct is dysfunctional. as is checks if item is locked. 
    }
    
    function _lock_store(uint32 storeIdx) internal {
      // make api call to physical device
      _inv.strg[storeIdx].locked = true;
    }
    
    function vend(Item _item, uint32 qty) external payable {
      // TODO: unlock storage => vend qty item
      // update item state
      if (qty > _item.cnt) {
        _unlock_store(this.find(_item));
        // TODO: vend here
        _item.cnt-=qty;
        _lock_store(this.find(_item));
      }
      // handles removing item if item wont be restocked
      needResupply(_item); 
    }
    
    function needResupply(Item _item) internal {
      if (_item.cnt == 0) {
        resupply(_item);
      } else if (_item.cnt == uint8(-1)) {
        this.remove(_item); //sends an item, but remove() takes an storeIdx. 
      }
    }
    
    function find(Item _item) external returns (uint32)  {
        for (uint32 i = 0; i < STORAGE_MAX; i++) {
            if (StringUtils.equal(_inv.strg[i].item.name, _item.name)) {
                 return i;
            }
        }
    }
    
    function remove(Item _item) external {
        _remove(this.find(_item));
    }
    
    function _remove(uint32 storeIdx) internal { 
      //probably should take item, and find its storeIdx
      require(msg.sender == _creator);
      delete _inv.strg[storeIdx];
      _inv.activeItems[storeIdx] = false;
      _stgIdx--;
    }
    
    function resupply(Item _item) internal {
      // TODO: call external resupply contract for item (at _item.resupply) 
      _item.resupply(); //<< Do that  <<
    }
    
    function turnOff() external {
      require(msg.sender == _creator);
      _running = false;
    }
}

// TODO: move into own file
//       populate the vending machine
/* contract vendMeUpFam {
  function popDefaultVendingMachine() {
    // TODO:
  }
} */
// NOTES:
// stock vending machine
// connect vending machine to ethereum network
