var web3Provider = null;
var Cafe;
const nullAddress = "0x0000000000000000000000000000000000000000";

function init(){
	initWeb3();
}

function initWeb3(){
  if (typeof web3 !== 'undefined' && typeof web3.currentProvider !== 'undefined'){
    web3Provider = web3.currentProvider;
    web3 = new Web3(web3Provider);
  } else {
    //console.error('No web3 provider found. Please install Metamask on your browser.');
    //alert('No web3 provider found. Please install Metamask on your browser.');
		console.error('Cài đặt Metamask để có thể nhập dữ liệu!');
    alert('Cài đặt Metamask để có thể nhập dữ liệu!');
	}
	initCafe();
	//TimUser("0x55bb954e71228a5f5b3f33e12e786872b8cd2111");
}

function initCafe(){
	$.getJSON('Cafe.json', function(data){
    // Get the necessary contract artifact file and instantiate it with truffle-contract
    Cafe = TruffleContract(data);

    // Set the provider for our contract
    Cafe.setProvider(web3Provider);

    // listen to the events emitted by our smart contract
    getEvents ();
    // We'll retrieve the Wrestlers addresses set in our contract using Web3.js
    //getFirstWrestlerAddress();
    //getSecondWrestlerAddress();
  });
}

function getEvents(){
  Cafe.deployed().then(function(instance) {
  var events = instance.allEvents(function(error, log){
    if (!error)
      $("#eventsList").prepend('<li>' + log.event + '</li>'); // Using JQuery, we will add new events to a list in our index.html
  });
  }).catch(function(err) {
   	console.log(err.message);
  });
}


//function that call when we hit button ok.
function ThemNguoiDung(){
	var userWalletAddress = $("#userWalletAddress").val();
		var userName          = $("#userName").val();
		var userContactNo     = $("#userContactNo").val();
		var userRoles         = $("#userRoles").val();
  web3.eth.getAccounts(function(error, accounts) {
  if (error) {
    console.log(error);
  } else {
    if(accounts.length <= 0) {
      alert("Chưa có tài khoản khả dụng, hãy đăng nhập tài khoản bằng metamask.")
    } else {
      Cafe.deployed().then(function(instance) {
        return instance.ThemUser(userWalletAddress,userName,userContactNo,userRoles);
      }).then(function(result) {
        console.log('Thêm người nhập thành công!');
				data[index]=userWalletAddress
      });
    }
  }
});
	console.log(data);
	$("#userFormModel").modal('hide');
	index++;
}
var index=0;
var data =["0x55bb954e71228a5f5b3f33e12e786872b8cd2111"];
/*function TimUser(diachi){
	Cafe.deployed().then(function(instance) {
	return instance.TimUser(diachi);
}).then(function(result) {
	if(result != nullAddress) {
		console.log(result);
	} else {
		$("#content-thongtinsv").text("?");
	}
}).catch(function(err) {
	console.log(err.message);
});
}*/
// When the page loads, this will call the init() function
$(function() {
  $(window).load(function() {
    init();
  });
});
