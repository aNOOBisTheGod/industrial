import 'package:bip39/bip39.dart' as bip39;
import 'package:ed25519_hd_key/ed25519_hd_key.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hex/hex.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';

class WalletManager {
  String? privateKey;
  var apiUrl = "https://ethereum.publicnode.com";
  // Replace with your API
  var httpClient = http.Client();

  void removePrivateKey() {
    final box = GetStorage();
    box.remove('privateKey');
  }

  Future<String> generateMnemonic() async {
    return await bip39.generateMnemonic();
  }

  Future<String> getPrivateKey(String mnemonic) async {
    final seed = bip39.mnemonicToSeed(mnemonic);
    final master = await ED25519_HD_KEY.getMasterKeyFromSeed(seed);
    final privateKey = HEX.encode(master.key);
    setPrivateKey(privateKey);
    return privateKey;
  }

  EthereumAddress getPublicKey(String privateKey) {
    final private = EthPrivateKey.fromHex(privateKey);
    final address = private.address;
    return address;
  }

  Future<void> setPrivateKey(String privateKey) async {
    GetStorage box = GetStorage();
    await box.write('privateKey', privateKey);
    this.privateKey = privateKey;
  }

  void loadPrivateKey() {
    GetStorage box = GetStorage();
    privateKey = box.read('privateKey');
  }

  Future<double> getBalance() async {
    var ethClient = Web3Client(apiUrl, httpClient);
    EthPrivateKey credentials = EthPrivateKey.fromHex('0x${privateKey!}');

    var address = credentials.address;
    EtherAmount balance = await ethClient.getBalance(address);
    return balance.getValueInUnit(EtherUnit.ether);
  }

  void sendTransaction(String receiver, EtherAmount txValue) async {
    if (privateKey == null) {
      throw Exception(
          'No private key was created! You can\'t perform your transaction without it');
    }
    var ethClient = Web3Client(apiUrl, httpClient);
    print(privateKey);
    EthPrivateKey credentials = EthPrivateKey.fromHex('0x${privateKey!}');
    print(credentials.address);
    EtherAmount etherAmount = await ethClient.getBalance(credentials.address);
    EtherAmount gasPrice = await ethClient.getGasPrice();

    print(etherAmount);

    await ethClient.sendTransaction(
      credentials,
      Transaction(
        to: EthereumAddress.fromHex(receiver),
        gasPrice: gasPrice,
        maxGas: 100000,
        value: txValue,
      ),
    );
  }
}
