pragma solidity >=0.4.0 <0.7.0;

import "./IMaster.sol";
import "./ICommunity.sol";

contract Community is ICommunity {
  address master;
  IMaster _Master;

  struct Tier {
    uint threshold;
    uint epochs;
    string name;
    string description;
    mapping (address => bool) isMemberOfThisTier;
  }

  struct Content {
    string tierName;
    string contentHash; // do I need to hide the content hash because security?
  }

  struct CommunityInfo {
    address root;
    address user;
    string name;
    uint deadline; //uint should be timestamp
    string image; // should point to storage hash of a default image
    Tier[] tiers;
    address[] likes;
    address[] follows;
    address[] fundedBy;
    Content[] content;
  }

  event Created(address createdBy, address _address, string name, uint time);
  event TierAdded(address community, uint threshold, uint epochs, string name, uint time);
  event ContentAdded(address community, string tierName, string contentHash, uint time);
  event FundingReceived(address community, address donor, uint amount, uint time);
  event CashedOut(address community, address recipient, uint amount, uint time);
  event Liked(address liker, address liked, uint time);
  event Unliked(address unliker, address unliked, uint time);
  event Followed(address follower, address followed, uint time);
  event Unfollowed(address unfollower, address unfollowed, uint time);

  modifier onlyOwner {
      require(msg.sender == CommunityInfo.user || msg.sender == CommunityInfo.root);
      _;
  }

  modifier onlyMember(address destination) {
    require(
      _Master.getType(destination) == _Master.Types.USER ||
      _Master.getType(destination) == _Master.Types.COMMUNITY
    );
    _;
  }

  constructor(address _root, string memory _name, address _master) public {
      master = _master;

      CommunityInfo.root = _root;
      CommunityInfo.user = msg.sender;
      CommunityInfo.name = _name;

      emit Created(msg.sender, address(this), _name, now);
  }

  function addTier(
      uint _threshold,
      uint _epochs,
      string memory _name,
      string memory _description // could be should use a contentHash instead
  )
      public onlyOwner
  {
      CommunityInfo.tiers.push(Tier({
          threshold: _threshold,
          epochs: _epochs,
          name: _name,
          description: _description
      }));

      emit TierAdded(address(this), _threshold, _epochs, _name, now);
  }

  function addContent(
      string memory _tierName,
      string memory _contentHash
  )
      public onlyOwner
  {
      assert(
          isTier(_tierName),
          "tier does not exist"
      );
      CommunityInfo.content.push(Content({
          tierName: _tierName,
          contentHash: _contentHash
      }));

      emit ContentAdded(address(this), _tierName, _contentHash, now);
  }

  // leaving out comment logic for now

  // should I put in like/unlike

  function cashOut(uint amount) public onlyOwner {
      CommunityInfo.root.transfer(amount);

      emit CashedOut(address(this), CommunityInfo.root, amount, now);
  }

  function getLiked(address liker) public onlyMember(liker) {
    require(liker == msg.sender);
    assert(
      !isIn(liker, CommunityInfo.likedBy),
      "user has already liked this"
    );
    CommunityInfo.likedBy.push(liker);

    emit Liked(liker, address(this), now);
  }

  function getUnliked(address unliker) public onlyMember(unliker) {
    require(unliker == msg.sender);
    assert(
      isIn(unliker, CommunityInfo.getLiked),
      "user has not yet liked this"
    );
    CommunityInfo.likedBy.pop(unliker);

    emit Unliked(unliker, address(this), now);
  }

  function getFollowed(address follower) public onlyMember(follower) {
    require(follower == msg.sender);
    assert(
      !isIn(follower, CommunityInfo.followedBy),
      "user has already followed"
    );
    CommunityInfo.likedBy.push(follower);

    emit Followed(follower, address(this), now);
  }

  function getUnfollowed(address unfollower) public onlyMember(unfollower) {
    require(unfollower == msg.sender);
    assert(
      isIn(unfollower, CommunityInfo.followedBy),
      "user has not yet followed"
    );
    CommunityInfo.followedBy.pop(unfollower);

    emit Unliked(unfollower, address(this), now);
  }

  function isTier(string memory _tierName) internal view {
    for(uint i = 0; i < CommunityInfo.tiers.length; i++){
        if(CommunityInfo.tiers[i].name == _tierName) return true;
    }
    return false;
  }

  function isIn(address toBeTested, address[] memory toCheck) internal view {
    for(uint i=0;i<toCheck.length;i++){
      if(toCheck[i] == toBeTested) return true;
    }
    return false;
  }
}
