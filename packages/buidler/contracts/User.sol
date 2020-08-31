 pragma solidity >=0.4.0 <0.7.0;

import "./IMaster.sol";
import "./Master.sol";
import "./IUser.sol";
import "./Community.sol";

contract User is IUser {
  address master;
  IMaster Master;

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

  UserInfo userInfo;

  event Liked(address liker, address liked, uint time);
  event Unliked(address unliker, address unliked, uint time);
  event Followed(address follower, address followed, uint time);
  event Unfollowed(address unfollower, address unfollowed, uint time);
  event Funded(address giver, address recipient, uint amountLocked, uint epochs, string epochType, uint time);
  event ProfileEdited(address user, string contentType, string contentHash, uint time);
  event CashedOut(address from, address to, uint amount, uint time);
  event AccountDeleted(address root, address user, uint time);

  modifier onlyOwner {
      require(msg.sender == userInfo.root);
      _;
  }

  modifier onlyMember(address destination) {
    require(
      Master.getType(destination) == Types.USER ||
      Master.getType(destination) == Types.COMMUNITY
    );
    _;
  }

  constructor(address _root, string memory _name) public override {
    master = msg.sender;
    Master = new IMaster(msg.sender);

    userInfo.root = _root;
    userInfo.name = _name;
  }

  function getUserInfo() public view returns(
      address root,
      string memory name,
      string memory image,
      string memory bio,
      address communityAddress,
      address[] memory likedBy,
      address[] memory followedBy,
      address[] memory amFunding,
      address[] memory amLiking,
      address[] memory amFollowing,
      address[] memory projects,
      bool community
    ) {
      return (
        userInfo.root,
        userInfo.name,
        userInfo.image,
        userInfo.bio,
        userInfo.communityAddress,
        userInfo.likedby,
        userInfo.followedBy,
        userInfo.amFunding,
        userInfo.amLiking,
        userInfo.amFollowing,
        userInfo.projects,
        userInfo.community
      );
    }

  function createCommunity(string memory name) public override onlyOwner {
    require(
      !userInfo.community,
      "You already have a community page"
    );

    userInfo.community = true;
    address communityContract = new Community(userInfo.root, name, master); // todo add boolean flag to determine project or not
    userInfo.communityAddress = communityContract;
    Master.addCommunity(userInfo.root, address(this), communityContract);
  }

  function createProject(string memory name) public override onlyOwner {
    address communityContract = new Community(userInfo.root, name); // todo add boolean flag to determine project or not
    userInfo.projects.push(communityContract);
    Master.addCommunity(userInfo.root, address(this), communityContract);
  }

  // could make it that only users can like, would simplify logic
  function like(address toLike) public override onlyOwner onlyMember(toLike) {
    // should implement check that haven't yet liked

    if(Master.getType(toLike) == Master.Types.USER){
      User UserToLike = new User(toLike);
      UserToLike.getLiked(address(this));
      userInfo.amLiking.push(toLike);

      emit Liked(address(this), toLike, now);
    } else if (Master.getType(toLike) == Master.Types.COMMUNITY) {
      Community CommunityToLike = new Community(toLike);
      CommunityToLike.getLiked(address(this));
      userInfo.amLiking.push(toLike);

      emit Liked(address(this), toLike, now);
    } else {
      revert("Something strange happened - you should not be seeing this");
    }
  }

  function unlike(address toUnlike) public override onlyOwner onlyMember(toUnlike) {
    // should implement check that have already liked

    if(Master.getType(toUnlike) == Master.Types.USER){
      User UserToUnlike = new User(toUnlike);
      UserToUnlike.getLiked(address(this));
      userInfo.amLiking.push(toUnlike);

      emit Unliked(address(this), toUnlike, now);
    } else if (Master.getType(toUnlike) == Master.Types.COMMUNITY) {
      Community CommunityToUnlike = new Community(toUnlike);
      CommunityToUnlike.getLiked(address(this));
      userInfo.amLiking.push(toUnlike);

      emit Unliked(address(this), toUnlike, now);
    } else {
      revert("Something strange happened - you should not be seeing this");
    }
  }

  function getLiked(address liker) public override onlyMember(liker) {
    require(
      liker == msg.sender,
      "unauthorized contract call"
    );
    assert(
      !isIn(liker, userInfo.likedBy),
      "user has already liked this"
    );
    userInfo.likedBy.push(liker);

    emit Liked(liker, address(this), now);
  }

  function getUnliked(address unliker) public override onlyMember(unliker) {
    require(
      unliker == msg.sender,
      "unauthorized contract call"
    );
    assert(
      isIn(unliker, userInfo.likedBy),
      "user has not yet liked this"
    );
    userInfo.likedBy.pop(unliker);

    emit Unliked(unliker, address(this), now);
  }

  function follow(address toFollow) public override onlyOwner onlyMember(toFollow) {
    // should implement check that haven't yet followed

    if(Master.getType(toFollow) == Master.Types.USER){
      User UserToFollow = new User(toFollow);
      UserToFollow.getFollowed(address(this));
      userInfo.amFollowing.push(toFollow);

      emit Liked(address(this), toFollow, now);
    } else if (Master.getType(toFollow) == Master.Types.COMMUNITY) {
      Community CommunityToFollow = new Community(toFollow);
      CommunityToFollow.getFollowed(address(this));
      userInfo.amFollowing.push(toFollow);

      emit Followed(address(this), toFollow, now);
    } else {
      revert("Something strange happened - you should not be seeing this");
    }
  }

  function unfollow(address toUnfollow) public override onlyOwner onlyMember(toUnfollow) {
    // should implement check that have already followed

    if(Master.getType(toUnfollow) == Master.Types.USER){
      User UserToUnfollow = new User(toUnfollow);
      UserToUnfollow.getFollowed(address(this));
      userInfo.amFollowing.pop(toUnfollow);

      emit Liked(address(this), toUnfollow, now);
    } else if (Master.getType(toUnfollow) == Master.Types.COMMUNITY) {
      Community CommunityToUnfollow = new Community(toUnfollow);
      CommunityToUnfollow.getFollowed(address(this));
      userInfo.amFollowing.pop(toUnfollow);

      emit Unfollowed(address(this), toUnfollow, now);
    } else {
      revert("Something strange happened - you should not be seeing this");
    }
  }

  function getFollowed(address follower) public override onlyMember(follower) {
    require(
      follower == msg.sender,
      "unauthorized contract call"
    );
    assert(
      !isIn(follower, userInfo.followedBy),
      "user has already followed"
    );
    userInfo.followedBy.push(follower);

    emit Followed(follower, address(this), now);
  }

  function getUnfollowed(address unfollower) public override onlyMember(unfollower) {
    require(
      unfollower == msg.sender,
      "unauthorized contract call"
    );
    assert(
      isIn(unfollower, userInfo.followedBy),
      "user has not yet liked this"
    );
    userInfo.followedBy.pop(unfollower);

    emit Unfollowed(unfollower, address(this), now);
  }

  //TODO: comment

  //TODO: fund/subscribe

  function editProfile(string memory contentType, string memory contentHash) public override onlyOwner {
      if(contentType == 'image') userInfo.image = contentHash;
      if(contentType == 'bio') userInfo.bio == contentHash;

      emit ProfileEdited(address(this), contentType, contentHash, now);
  }

  function cashOut(uint amount) public override onlyOwner {
      userInfo.root.transfer(amount);

      emit CashedOut(address(this), userInfo.root, amount, now);
  }

  function deleteAccount() public override onlyOwner {
      userInfo.root.transfer(this.value);
      Master.deleteUser(address(this));

      emit AccountDeleted(msg.sender, address(this), now);
  }

  function isIn(address toBeTested, address[] memory toCheck) internal view {
    for(uint i=0;i<toCheck.length;i++){
      if(toCheck[i] == toBeTested) return true;
    }
    return false;
  }
}
