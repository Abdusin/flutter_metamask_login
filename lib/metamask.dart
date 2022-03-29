import 'dart:math';
import 'package:js/js.dart';

@JS('window')
external dynamic get window;
@JS('window.ethereum')
external dynamic get ethereum;
@JS('window.address')
external dynamic get _address;
@JS('window.sign')
external dynamic get _sign;
@JS('eval')
external dynamic get eval;

String randomId() {
  var number = '';
  for (var i = 0; i < 4; i++) {
    number += '${Random().nextInt(10)}';
  }
  return number;
}

class MetaMask {
  String? address;
  String? signature;

  bool get isSupported => ethereum != null;

  Future<bool> login() async {
    try {
      if (ethereum == null) {
        return false;
      }
      var id = randomId();
      var message = 'Please log in to MetaMask $id';

      eval('''
      async function setter(){
        var provider = new ethers.providers.Web3Provider(window.ethereum);
        await provider.send("eth_requestAccounts", []);
        window.address = await provider.getSigner().getAddress();
        window.sign = await provider.getSigner().signMessage("$message");
      }
      setter();
      ''');
      while (_address == null || _sign == null) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      address = _address.toString();
      signature = _sign.toString();
      return true;
    } catch (e) {
      return false;
    }
  }
}
