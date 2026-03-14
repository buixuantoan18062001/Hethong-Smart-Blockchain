pragma solidity ^0.4.23;

import "./SupplyChainStorageOwnable.sol";

contract SupplyChainCafe is SupplyChainStorageOwnable {

    constructor() public {
        authorizedCaller[msg.sender] = 1;
        emit AuthorizedCaller(msg.sender);
    }

    /* Events */
    event AuthorizedCaller(address caller);
    event DeAuthorizedCaller(address caller);

    event PerformCultivation(address indexed user, address indexed batchNo);
    event DoneNongTrai(address indexed user, address indexed batchNo);
    event DoneThuhoach(address indexed user, address indexed batchNo);
    event DoneVanchuyen(address indexed user, address indexed batchNo);
    event DoneSanxuat(address indexed user, address indexed batchNo);
    event DoneTieuthu(address indexed user, address indexed batchNo);


    event UserUpdate(address indexed user, string name, string contactNo, string role, bool isActive);
    event UserRoleUpdate(address indexed user, string role);
    /* Modifiers */

    modifier onlyAuthCaller(){
        require(authorizedCaller[msg.sender] == 1);
        _;
    }

    /* User Related */
    struct user {
        string name;
        string contactNo;
        bool isActive;
    }

    mapping(address => user) userDetails;
    mapping(address => string) userRole;

    /* Caller Mapping */
    mapping(address => uint8) authorizedCaller;

    /* authorize caller */
    function authorizeCaller(address _caller) public onlyOwner returns(bool)
    {
        authorizedCaller[_caller] = 1;
        emit AuthorizedCaller(_caller);
        return true;
    }

    /* deauthorize caller */
    function deAuthorizeCaller(address _caller) public onlyOwner returns(bool)
    {
        authorizedCaller[_caller] = 0;
        emit DeAuthorizedCaller(_caller);
        return true;
    }

    /*User Roles
        SUPER_ADMIN,
        FARM_INSPECTION,
        thuhoach,
        vanchuyen,
        sanxuat,
        tieuthu
    */

    /* Process Related */
     struct basicDetails {
        string registrationNo;
        string nongtrainame;
        string diachinongtrai;
        string vanchuyenName;
        string sanxuatName;

    }

    struct nongtrai {
        string loaicafe;
        string hatgiong;
        string phanbon;
    }

    struct thuhoach {
        string cafe;
        string nhietdo;
        string doam;
    }

    struct vanchuyen {
        string diachiden;
        string tenship;
        string idship;
        uint256 soluong;
        uint256 departureDateTime;
        uint256 thoigianuoctinh;
        string sanxuat;
    }

    struct sanxuat {
        uint256 soluong;
        uint256 ngayden;
        string loai;
        string tenkho;
        string diachikho;
        string tieuthu;
    }

    struct tieuthu {
        uint256 soluong;
        uint256 ngayden;
        uint256 thoihan;
        string loai;
    }

    mapping (address => basicDetails) batchBasicDetails;
    mapping (address => nongtrai) batchnongtrai;
    mapping (address => thuhoach) batchthuhoach;
    mapping (address => vanchuyen) batchvanchuyen;
    mapping (address => sanxuat) batchsanxuat;
    mapping (address => tieuthu) batchtieuthu;
    mapping (address => string) nextAction;

    /*Initialize struct pointer*/
    user userDetail;
    basicDetails basicDetailsData;
    nongtrai nongtraiData;
    thuhoach thuhoachData;
    vanchuyen vanchuyenData;
    sanxuat sanxuatData;
    tieuthu tieuthuData;



    function ChuoiRong (string Chuoi) pure public returns (bool) {
        bytes memory _value = bytes (Chuoi);
        if (_value.length == 0)
            return true;
        return false;
    }


    function NguoiDungTonTai (address diaChi) constant private returns (bool) {
        if (!ChuoiRong (userDetails [diaChi].name)) {
            return true;
        }
        return false;
    }

    /* Get User Role */
    function getUserRole(address _userAddress) public onlyAuthCaller view returns(string)
    {
        return userRole[_userAddress];
    }

    /* Get Next Action  */
    function getNextAction(address _batchNo) public onlyAuthCaller view returns(string)
    {
        return nextAction[_batchNo];
    }

    /*set user details*/
    function setUser(address _userAddress,
                     string _name,
                     string _contactNo,
                     string _role,
                     bool _isActive) public onlyAuthCaller view returns(bool){

        /*store data into struct*/
        userDetail.name = _name;
        userDetail.contactNo = _contactNo;
        userDetail.isActive = _isActive;

        /*store data into mapping*/
        userDetails[_userAddress] = userDetail;
        userRole[_userAddress] = _role;

        emit UserUpdate(_userAddress,_name,_contactNo,_role,_isActive);
        emit UserRoleUpdate(_userAddress,_role);

        return true;
    }
    /* Create/Update User For Admin  */
    function updateUserForAdmin(address _userAddress, string _name, string _contactNo, string _role, bool _isActive) public returns(bool)
    {
        require(_userAddress != address(0));

        /* Call Storage Contract */
        bool status = setUser(_userAddress, _name, _contactNo, _role, _isActive);

         /*call event*/
        emit UserUpdate(_userAddress,_name,_contactNo,_role,_isActive);
        emit UserRoleUpdate(_userAddress,_role);

        return status;
    }

	/* Create/Update User */
    function updateUser(string _name, string _contactNo, string _role, bool _isActive) public returns(bool)
    {
        require(msg.sender != address(0));

        /* Call Storage Contract */
        bool status = setUser(msg.sender, _name, _contactNo, _role, _isActive);

         /*call event*/
        emit UserUpdate(msg.sender,_name,_contactNo,_role,_isActive);
        emit UserRoleUpdate(msg.sender,_role);

        return status;
    }
    /*get user details*/
    function getUser(address _userAddress) public onlyAuthCaller view returns(string name,
                                                                    string contactNo,
                                                                    string role,
                                                                    bool isActive
                                                                ){

        /*Getting value from struct*/
        user memory tmpData = userDetails[_userAddress];

        return (tmpData.name, tmpData.contactNo, userRole[_userAddress], tmpData.isActive);
    }
    function getUserAdmin(address _userAddress) public view returns(string name, string contactNo, string role, bool isActive){
        require(_userAddress != address(0));

        /*Getting value from struct*/
       (name, contactNo, role, isActive) = getUser(_userAddress);

       return (name, contactNo, role, isActive);
    }
    /*get batch basicDetails*/
    function getBasicDetails(address _batchNo) public onlyAuthCaller view returns(string registrationNo,
                             string nongtrainame,
                             string diachinongtrai,
                             string vanchuyenName,
                             string sanxuatName) {

        basicDetails memory tmpData = batchBasicDetails[_batchNo];

        return (tmpData.registrationNo,tmpData.nongtrainame,tmpData.diachinongtrai,tmpData.vanchuyenName,tmpData.sanxuatName);
    }

    /*set batch basicDetails*/
    function setBasicDetails(string _registrationNo,
                             string _nongtrainame,
                             string _diachinongtrai,
                             string _vanchuyenName,
                             string _sanxuatName

                            ) public onlyAuthCaller returns(address) {

        uint tmpData = uint(keccak256(msg.sender, now));
        address batchNo = address(tmpData);
        basicDetailsData.registrationNo = _registrationNo;
        basicDetailsData.nongtrainame = _nongtrainame;
        basicDetailsData.diachinongtrai = _diachinongtrai;
        basicDetailsData.vanchuyenName = _vanchuyenName;
        basicDetailsData.sanxuatName = _sanxuatName;

        batchBasicDetails[batchNo] = basicDetailsData;

        nextAction[batchNo] = 'nongtrai';

        emit PerformCultivation(msg.sender, batchNo);

        return batchNo;
    }

    /*set farm Inspector data*/
    function setnongtraiData(address batchNo,
                                    string _loaicafe,
                                    string _hatgiong,
                                    string _phanbon) public returns(bool){
	require (NguoiDungTonTai (msg.sender));
        nongtraiData.loaicafe = _loaicafe;
        nongtraiData.hatgiong = _hatgiong;
        nongtraiData.phanbon = _phanbon;
        batchnongtrai[batchNo] = nongtraiData;
        nextAction[batchNo] = 'thuhoach';

        emit DoneNongTrai(msg.sender, batchNo);

        return true;
    }

    /*get farm inspactor data*/
    function getnongtraiData(address batchNo) public onlyAuthCaller view returns (string loaicafe,string hatgiong,string phanbon){

        nongtrai memory tmpData = batchnongtrai[batchNo];
        return (tmpData.loaicafe, tmpData.hatgiong, tmpData.phanbon);
    }


    /*set thuhoach data*/
    function setthuhoachData(address batchNo,
                              string _cafe,
                              string _nhietdo,
                              string _doam) public returns(bool){
	require (NguoiDungTonTai (msg.sender));
        thuhoachData.cafe = _cafe;
        thuhoachData.nhietdo = _nhietdo;
        thuhoachData.doam = _doam;

        batchthuhoach[batchNo] = thuhoachData;

        nextAction[batchNo] = 'vanchuyen';

        emit DoneThuhoach(msg.sender, batchNo);

        return true;
    }

    /*get farm thuhoach data*/
    function getthuhoachData(address batchNo) public onlyAuthCaller view returns(string cafe,
                                                                                           string nhietdo,
                                                                                           string doam){

        thuhoach memory tmpData = batchthuhoach[batchNo];
        return (tmpData.cafe, tmpData.nhietdo, tmpData.doam);
    }

    /*set vanchuyen data*/
    function setvanchuyenData(address batchNo,
                              uint256 _soluong,
                              string _diachiden,
                              string _tenship,
                              string _idship,
                              uint256 _thoigianuoctinh,
                              string _sanxuat) public returns(bool){
        require (NguoiDungTonTai (msg.sender));
        vanchuyenData.soluong = _soluong;
        vanchuyenData.diachiden = _diachiden;
        vanchuyenData.tenship = _tenship;
        vanchuyenData.idship = _idship;
        vanchuyenData.departureDateTime = now;
        vanchuyenData.thoigianuoctinh = _thoigianuoctinh;
        vanchuyenData.sanxuat = _sanxuat;

        batchvanchuyen[batchNo] = vanchuyenData;
        nextAction[batchNo] = 'sanxuat';
        emit DoneVanchuyen(msg.sender, batchNo);
        return true;
    }

    /*get vanchuyen data*/
    function getvanchuyenData(address batchNo) public onlyAuthCaller view returns(uint256 soluong,
                                                                string diachiden,
                                                                string tenship,
                                                                string idship,
                                                                uint256 departureDateTime,
                                                                uint256 thoigianuoctinh,
                                                                string sanxuat){


        vanchuyen memory tmpData = batchvanchuyen[batchNo];


        return (tmpData.soluong,
                tmpData.diachiden,
                tmpData.tenship,
                tmpData.idship,
                tmpData.departureDateTime,
                tmpData.thoigianuoctinh,
                tmpData.sanxuat);


    }


    /*set sanxuat data*/
    function setsanxuatData(address batchNo,
                              uint256 _soluong,
                              string _loai,
                              string _tenkho,
                              string _diachikho,
                              string _tieuthu) public returns(bool){
        require (NguoiDungTonTai (msg.sender));
        sanxuatData.soluong = _soluong;
        sanxuatData.loai = _loai;
        sanxuatData.ngayden = now;
        sanxuatData.tenkho = _tenkho;
        sanxuatData.diachikho = _diachikho;
        sanxuatData.tieuthu = _tieuthu;

        batchsanxuat[batchNo] = sanxuatData;

        nextAction[batchNo] = 'tieuthu';

        emit DoneSanxuat(msg.sender, batchNo);

        return true;
    }

    /*get sanxuat data*/
    function getsanxuatData(address batchNo) public onlyAuthCaller view returns(uint256 soluong,
                                                                                        string loai,
                                                                                        uint256 ngayden,
                                                                                        string tenkho,
                                                                                        string diachikho,
                                                                                        string tieuthu){

        sanxuat memory tmpData = batchsanxuat[batchNo];


        return (tmpData.soluong,
                tmpData.loai,
                tmpData.ngayden,
                tmpData.tenkho,
                tmpData.diachikho,
                tmpData.tieuthu);


    }

    /*set Proccessor data*/
    function settieuthuData(address batchNo,
                              uint256 _soluong,
                              uint256 _thoihan,
                              string _loai) public returns(bool){

        require (NguoiDungTonTai (msg.sender));
        tieuthuData.soluong = _soluong;
        tieuthuData.ngayden = now;
        tieuthuData.thoihan = _thoihan;
        tieuthuData.loai = _loai;

        batchtieuthu[batchNo] = tieuthuData;

        nextAction[batchNo] = 'DONE';

        emit DoneTieuthu(msg.sender, batchNo);

        return true;
    }


    /*get tieuthu data*/
    function gettieuthuData( address batchNo) public onlyAuthCaller view returns(       uint256 soluong,
                                                                                        uint256 ngayden,
                                                                                        uint256 thoihan,
                                                                                        string loai){

        tieuthu memory tmpData = batchtieuthu[batchNo];


        return (
                tmpData.soluong,
                tmpData.ngayden,
                tmpData.thoihan,
                tmpData.loai);


    }


}
