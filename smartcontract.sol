// SPDX-License-Identifier: GPL-3.0
// Coded by hoang.lv173128
pragma solidity >=0.7.0 <0.9.0;

contract MyContract{
    address owner;

    struct Course {
        uint id;
        string code;
        string name;
        string date;
        string issuer;
        string ipfsHash;
    }
    mapping(string => uint) private courseCodes; // tu code => id
    mapping(uint => Course)  private courses; //// danh sach khoa hoc
    uint[] private courseIds; // danh sach id cua khoa hoc
    
    
    struct User {
        uint id;
        string code;
        string name;
        address _address;
    }
    
    mapping(uint => User) private users; // danh sach nguoi dung
    uint[] private administratorIds; // danh sach id cua admin
    uint[] private studentIds; // danh sach id cua student
    mapping(string => uint) private userCodes;
    mapping(address => bool) private isIssuer; // kiem tra address co phai admin
    
    struct Certificate {
        uint id;
        uint courseId; // id khoa hoc
        uint studentId; // thong tin nguoi nhan
        string ipfsHash;
    }
    
    mapping(uint => Certificate) private certificates;
    uint[] private certificateIds;
    mapping(string => uint) private certificateHash; //  verify
    mapping(uint => uint[]) private certificateOfCourse; // danh sach cert cua course
    
    function addCourse(uint _id, string memory _code, string memory _name, string memory _date, string memory _issuer, string memory _ipfsHash) public{
        require(isIssuer[msg.sender] == true, "Must be Administrator");
        require(courseCodes[_code] == 0, "The course already exists");

        courses[_id] = Course(_id,_code, _name,_date, _issuer,  _ipfsHash);
        courseIds.push(_id);
        courseCodes[_code] = _id;
    }
    
    function addCertificate(uint _id, uint _courseId, uint _studentId, string memory _studenCode, string memory _studentName, string memory _ipfsHash) public{
        require(isIssuer[msg.sender] == true, "Must be Administrator");
        require(certificateHash[_ipfsHash] == 0, "The certificate already exists");
        
        // check student ton tai
        uint studentId = userCodes[_studenCode];
        uint[] memory certs = certificateOfCourse[_courseId];
        for (uint i = 0; i < certs.length; i++){
            Certificate memory cert = certificates[certs[i]];
            if(cert.studentId == studentId){
                revert("Student has been granted a certificate");
            }
        }

        if (studentId != 0){
            setUserById(studentId, _studenCode, _studentName, address(0)); // cap nhat thong tin
            certificates[_id] = Certificate(_id, _courseId, studentId, _ipfsHash);
            certificateIds.push(_id);
            certificateHash[_ipfsHash] = _id;
        }
        else{
            // them moi studentId
            addStudent(_studentId, _studenCode, _studentName);
            certificates[_id] = Certificate(_id, _courseId, _studentId, _ipfsHash);
            certificateIds.push(_id);
            certificateHash[_ipfsHash] = _id;
        }
        
        certificateOfCourse[_courseId].push(_id);
    }
    
    function addAdmin(uint _id,string memory _code, string memory _name, address _address) public {
        require(isIssuer[msg.sender] == true, "Must be Administrator");
        require(userCodes[_code] == 0, "The admin already exists");
        require(isIssuer[_address] == false, "This address is already registered");
        
        users[_id] = User(_id,_code, _name, _address);
        userCodes[_code]=_id;
        administratorIds.push(_id);
        isIssuer[_address] = true;
    }
    
    function addStudent(uint _id,string memory _code,string memory _name) public {
        require(isIssuer[msg.sender] == true, "Must be Administrator");
        require(userCodes[_code] == 0, "The student already exists");
        
        users[_id] = User(_id,_code, _name,address(0));
        userCodes[_code]=_id;
        studentIds.push(_id);
    }
    
    function getCourses () public view returns (Course[] memory){
        Course[] memory ret = new Course[](courseIds.length);
        for (uint i = 0; i < courseIds.length; i++) {
            ret[i] = courses[courseIds[i]];
        }
        return ret;
    }

    function getAdmins () public view returns (User[] memory){
        User[] memory ret = new User[](administratorIds.length);
        for (uint i = 0; i < administratorIds.length; i++) {
            ret[i] = users[administratorIds[i]];
        }
        return ret;
    }
    
    function getCertificateOfCourse (uint _id) public view returns (User[] memory, Certificate[] memory){
        User[] memory ret = new User[](certificateOfCourse[_id].length);
        Certificate[] memory certs = new Certificate[](certificateOfCourse[_id].length);
        for (uint i = 0; i < certificateOfCourse[_id].length; i++) {
            uint certificateId = certificateOfCourse[_id][i];
            Certificate memory certificate = certificates[certificateId];
            User memory user = users[certificate.studentId];
            ret[i] = user;
            certs[i] = certificate;
        }
        return (ret, certs);        
    }
    
    function setCourseById (uint _id, string memory _code, string memory _name, string memory _date, string memory _issuer, string memory _ipfsHash) public {
        require(isIssuer[msg.sender] == true, "Must be Administrator");
        require(courseCodes[_code] == 0 || courseCodes[_code] == _id, "The course already exists");

        Course storage course = courses[_id];
        course.name = _name;
        course.date = _date;
        course.issuer = _issuer;
        course.ipfsHash = _ipfsHash;
        
        delete courseCodes[course.code];
        courseCodes[_code] = _id;
        course.code = _code;
    }

    function setUserById (uint _id, string memory _code, string memory _name, address _address) public {
        require(isIssuer[msg.sender] == true, "Must be Administrator");
        User storage user = users[_id];
        user.name = _name;
        user._address = _address;

        delete userCodes[user.code];
        userCodes[_code] = _id;
        user.code = _code;
    }

    function deleteCourseById (uint _id) public {
        require(isIssuer[msg.sender] == true, "Must be Administrator");
        uint index = 0;
        for (uint i = 0; i < courseIds.length; i++){
            if (courseIds[i] == _id){
                index = i;
                break;
            }
        }
        
        courseIds[index] = courseIds[courseIds.length - 1];
        courseIds.pop();
        delete courseCodes[courses[_id].code];
        delete courses[_id];
    }
    
    function deleteAdminById (uint _id) public {
        require(isIssuer[msg.sender] == true, "Must be Administrator");
        require(users[_id]._address != owner, "Cannot delete owner");
        uint index = 0;
        for (uint i = 0; i < administratorIds.length; i++){
            if (administratorIds[i] == _id){
                index = i;
                break;
            }
        }
        

        address issuerAddr = users[_id]._address;
        administratorIds[index] = administratorIds[administratorIds.length-1];
        administratorIds.pop();
        delete userCodes[users[_id].code];
        delete users[_id];
        delete isIssuer[issuerAddr];
    }
    
    function deleteCertificateById (uint _id) public {
        require(isIssuer[msg.sender] == true, "Must be Administrator");
        uint index = 0;
        for (uint i = 0; i < certificateIds.length; i++){
            if (certificateIds[i] == _id){
                index = i;
                break;
            }
        }
        
        certificateIds[index] = certificateIds[certificateIds.length - 1];
        certificateIds.pop();
        
        uint courseId = certificates[_id].courseId;
        for (uint i = 0; i < certificateOfCourse[courseId].length; i++){
            if (certificateOfCourse[courseId][i] == _id){
                index = i;
                break;
            }
        }
        
        certificateOfCourse[courseId][index] = certificateOfCourse[courseId][certificateOfCourse[courseId].length - 1];
        certificateOfCourse[courseId].pop();
        
        
        delete certificateHash[certificates[_id].ipfsHash];
        delete certificates[_id];
    }

    function getCertificateById(uint _id) public view returns (Certificate memory, Course memory, User memory){
        Certificate memory cert = certificates[_id];
        User memory student = users[cert.studentId];
        Course memory course = courses[cert.courseId];
        return (cert, course, student);
    }

    function verifyCertificate(string memory _ipfsHash) public view returns (bool){
        uint id = certificateHash[_ipfsHash];
        if (id==0){
            return false;
        }
        else{
            return true;
        }
    }
    
    constructor() {
        owner = msg.sender;
        users[block.timestamp] = User(block.timestamp,"OWNER", "Admin", msg.sender);
        userCodes["OWNER"]=block.timestamp;
        administratorIds.push(block.timestamp);
        isIssuer[msg.sender] = true;
    }
    
 
}
