pragma solidity >=0.4.0 <0.7.0;

import "./IMaster.sol";
import "./Master.sol";
import "./IUser.sol";
import "./Community.sol";

contract User is IUser {
  address master;
  IMaster _Master;

  enum Types {
    USER,
    COMMUNITY,
    DELETED
  }

  struct UserInfo {
    address payable root;
    string name;
    string image; // should point to storage hash of a default image
    string bio; // I think this should also just be a link
    address communityAddress;
    address[] likedBy;
    address[] followedBy;
    address[] amFunding;
    address[] amLiking;
    address[] amFollowing;
    address[] projects;
    bool community;
  }

  event Liked(address liker, address liked, uint time);
  event Unliked(address unliker, address unliked, uint time);
  event Followed(address follower, address followed, uint time);
  event Unfollowed(address unfollower, address unfollowed, uint time);
  event Funded(address giver, address recipient, uint amountLocked, uint epochs, string epochType, uint time);
  event ProfileEdited(address user, string contentType, string contentHash, uint time);
  event CashedOut(address from, address to, uint amount, uint time);
  event AccountDeleted(address root, address user, uint time);

  modifier onlyOwner {
      require(msg.sender == User.root);
      _;
  }

  modifier onlyMember(address destination) {
    require(
      _Master.getType(destination) == Types.USER ||
      _Master.getType(destination) == Types.COMMUNITY
    );
    _;
  }

  constructor(address _root, string memory _name) public {
    master = msg.sender;
    _Master = new Master();

    UserInfo.root = _root;
    UserInfo.name = _name;
  }

  function createCommunity(string memory name) public onlyOwner {
    require(
      !UserInfo.community,
      "You already have a community page"
    );

    User.community = true;
    address communityContract = new Community(User.root, name, master); // todo add boolean flag to determine project or not
    UserInfo.communityAddress = communityContract;
    _Master.addCommunity(User.root, address(this), communityContract);
  }

  function createProject(string memory name) public onlyOwner {
    address communityContract = new Community(User.root, name); // todo add boolean flag to determine project or not
    UserInfo.projects.push(communityContract);
    _Master.addCommunity(User.root, address(this), communityContract);
  }

  // could make it that only users can like, would simplify logic
  function like(address toLike) public onlyOwner onlyMember(toLike) {
    // should implement check that haven't yet liked

    if(_Master.getType(toLike) == _Master.Types.USER){
      User UserToLike = new User(toLike);
      UserToLike.getLiked(address(this));
      UserInfo.amLiking.push(toLike);

      emit Liked(address(this), toLike, now);
    } else if (_Master.getType(toLike) == _Master.Types.COMMUNITY) {
      Community CommunityToLike = new Community(toLike);
      CommunityToLike.getLiked(address(this));
      UserInfo.amLiking.push(toLike);

      emit Liked(address(this), toLike, now);
    } else {
      revert("Something strange happened - you should not be seeing this");
    }
  }

  function unlike(address toUnlike) public onlyOwner onlyMember(toUnlike) {
    // should implement check that have already liked

    if(_Master.getType(toUnlike) == _Master.Types.USER){
      User UserToUnlike = new User(toUnlike);
      UserToUnlike.getLiked(address(this));
      UserInfo.amLiking.push(toUnlike);

      emit Unliked(address(this), toUnlike, now);
    } else if (_Master.getType(toUnlike) == _Master.Types.COMMUNITY) {
      Community CommunityToUnlike = new Community(toUnlike);
      CommunityToUnlike.getLiked(address(this));
      UserInfo.amLiking.push(toUnlike);

      emit Unliked(address(this), toUnlike, now);
    } else {
      revert("Something strange happened - you should not be seeing this");
    }
  }

  function getLiked(address liker) public onlyMember(liker) {
    require(
      liker == msg.sender,
      "unauthorized contract call"
    );
    assert(
      !isIn(liker, UserInfo.likedBy),
      "user has already liked this"
    );
    UserInfo.likedBy.push(liker);

    emit Liked(liker, address(this), now);
  }

  function getUnliked(address unliker) public onlyMember(unliker) {
    require(
      unliker == msg.sender,
      "unauthorized contract call"
    );
    assert(
      isIn(unliker, UserInfo.likedBy),
      "user has not yet liked this"
    );
    UserInfo.likedBy.pop(unliker);

    emit Unliked(unliker, address(this), now);
  }

  function follow(address toFollow) public onlyOwner onlyMember(toFollow) {
    // should implement check that haven't yet followed

    if(_Master.getType(toFollow) == _Master.Types.USER){
      User UserToFollow = new User(toFollow);
      UserToFollow.getFollowed(address(this));
      UserInfo.amFollowing.push(toFollow);

      emit Liked(address(this), toFollow, now);
    } else if (_Master.getType(toFollow) == _Master.Types.COMMUNITY) {
      Community CommunityToFollow = new Community(toFollow);
      CommunityToFollow.getFollowed(address(this));
      UserInfo.amFollowing.push(toFollow);

      emit Followed(address(this), toFollow, now);
    } else {
      revert("Something strange happened - you should not be seeing this");
    }
  }

  function unfollow(address toUnfollow) public onlyOwner onlyMember(toUnfollow) {
    // should implement check that have already followed

    if(_Master.getType(toUnfollow) == _Master.Types.USER){
      User UserToUnfollow = new User(toUnfollow);
      UserToUnfollow.getFollowed(address(this));
      UserInfo.amFollowing.pop(toUnfollow);

      emit Liked(address(this), toUnfollow, now);
    } else if (_Master.getType(toUnfollow) == _Master.Types.COMMUNITY) {
      Community CommunityToUnfollow = new Community(toUnfollow);
      CommunityToUnfollow.getFollowed(address(this));
      UserInfo.amFollowing.pop(toUnfollow);

      emit Unfollowed(address(this), toUnfollow, now);
    } else {
      revert("Something strange happened - you should not be seeing this");
    }
  }

  function getFollowed(address follower) public onlyMember(follower) {
    require(
      follower == msg.sender,
      "unauthorized contract call"
    );
    assert(
      !isIn(follower, UserInfo.followedBy),
      "user has already followed"
    );
    UserInfo.followedBy.push(follower);

    emit Followed(follower, address(this), now);
  }

  function getUnfollowed(address unfollower) public onlyMember(unfollower) {
    require(
      unfollower == msg.sender,
      "unauthorized contract call"
    );
    assert(
      isIn(unfollower, UserInfo.followedBy),
      "user has not yet liked this"
    );
    UserInfo.followedBy.pop(unfollower);

    emit Unfollowed(unfollower, address(this), now);
  }

  //TODO: comment

  //TODO: fund

  function editProfile(string memory contentType, string memory contentHash) public onlyOwner {
      if(contentType == 'image') UserInfo.image = contentHash;
      if(contentType == 'bio') UserInfo.bio == contentHash;

      emit ProfileEdited(address(this), contentType, contentHash, now);
  }

  function cashOut(uint amount) public onlyOwner {
      UserInfo.root.transfer(amount);

      emit CashedOut(address(this), UserInfo.root, amount, now);
  }

  function deleteAccount() public onlyOwner {
      UserInfo.root.transfer(this.value);
      _Master.deleteUser(address(this));

      emit AccountDeleted(msg.sender, address(this), now);
  }

  function isIn(address toBeTested, address[] memory toCheck) internal view {
    for(uint i=0;i<toCheck.length;i++){
      if(toCheck[i] == toBeTested) return true;
    }
    return false;
  }
}
