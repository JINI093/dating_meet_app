'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"canvaskit/skwasm.js": "1ef3ea3a0fec4569e5d531da25f34095",
"canvaskit/skwasm_heavy.js": "413f5b2b2d9345f37de148e2544f584f",
"canvaskit/canvaskit.js.symbols": "58832fbed59e00d2190aa295c4d70360",
"canvaskit/skwasm.wasm": "264db41426307cfc7fa44b95a7772109",
"canvaskit/canvaskit.js": "140ccb7d34d0a55065fbd422b843add6",
"canvaskit/chromium/canvaskit.js.symbols": "193deaca1a1424049326d4a91ad1d88d",
"canvaskit/chromium/canvaskit.js": "5e27aae346eee469027c80af0751d53d",
"canvaskit/chromium/canvaskit.wasm": "24c77e750a7fa6d474198905249ff506",
"canvaskit/skwasm.js.symbols": "0088242d10d7e7d6d2649d1fe1bda7c1",
"canvaskit/skwasm_heavy.js.symbols": "3c01ec03b5de6d62c34e17014d1decd3",
"canvaskit/canvaskit.wasm": "07b9f5853202304d3b0749d9306573cc",
"canvaskit/skwasm_heavy.wasm": "8034ad26ba2485dab2fd49bdd786837b",
"flutter.js": "888483df48293866f9f41d3d9274a779",
"manifest.json": "a373997e58b1d9d5404231912df8982f",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"main.dart.js": "b9b78ee334b3a7b5b9ce3f7d874cec0b",
"version.json": "dbe977b2b9a0a5c2a457b92098c8a93c",
"assets/NOTICES": "24178be57001d4913a109fe639dec42c",
"assets/fonts/MaterialIcons-Regular.otf": "35ca77fbbf9fd4b7681261f9a7030938",
"assets/AssetManifest.json": "ec930d5b336bf41ce04e9a4479b94233",
"assets/assets/fonts/Pretendard-Thin.otf": "32c8b7e405cd546866e5ef1d33179cba",
"assets/assets/fonts/Pretendard-SemiBold.otf": "6fe301765c4f438e2034a0a47b609c61",
"assets/assets/fonts/Pretendard-Bold.otf": "f8a9b84216af5155ffe0e8661203f36f",
"assets/assets/fonts/Pretendard-ExtraLight.otf": "049bb07edff45e5817fa4f892ebabe98",
"assets/assets/fonts/Pretendard-Regular.otf": "84c0ea9d65324c758c8bd9686207afea",
"assets/assets/fonts/Pretendard-ExtraBold.otf": "67e8e4773c05f2988c52dfe6ea337f33",
"assets/assets/fonts/Pretendard-Medium.otf": "13a352bd44156de92cce335ce93cd02d",
"assets/assets/fonts/Pretendard-Black.otf": "de507f665f6ea63a94678e529b2a4ff0",
"assets/assets/fonts/Pretendard-Light.otf": "de308b576c70af4871d436e89918fdf6",
"assets/assets/background/image%252012.png": "5847e7727fbca695acd1c22d5e2974cf",
"assets/assets/icons/ic_vip_home.png": "0e6d522a1fb72af737f0d310af98b043",
"assets/assets/icons/more.png": "c9acbaec2422e4e2e427f80a5ef6077a",
"assets/assets/icons/ic_polygon_exchange.png": "be3677ae188a5ab2ea19e8874474336c",
"assets/assets/icons/4.png": "fc039292993b871f0a23a58473db0360",
"assets/assets/icons/out.png": "e52f3174a1a8dde44cac7907dc99a503",
"assets/assets/icons/m_more9.png": "02917e34bf300853bf23f94ea9f1ba17",
"assets/assets/icons/ic_exchange_point.png": "15ba7c1d01aa52a12f2465952b50ee12",
"assets/assets/icons/ic_sort_superchat.png": "80893c63e584209c6389e7f75742d32c",
"assets/assets/icons/m_profile1.png": "709a8cd614e66f5fc8476af8700d6f46",
"assets/assets/icons/m_super3.png": "30022079856edf83636659657e7bcc9c",
"assets/assets/icons/m_heart5.png": "c4945d940d49e697b73c2b1e845206db",
"assets/assets/icons/m_profile7.png": "9e61fbbe71fdc96d6da9168f3b1bee06",
"assets/assets/icons/m_profile8.png": "4f9daa0057113aacaa3544df7310a1ab",
"assets/assets/icons/m_heart3.png": "de0c3d2b3a9efaab7027aada34b686de",
"assets/assets/icons/m_profile10.png": "6b752f8137a2b021e63f9b237201a2e9",
"assets/assets/icons/icon_like_superchat.png": "4b4346a23d746ea9f9384f2197ca356e",
"assets/assets/icons/VIP_Bronze.png": "e47720b7a98f8ebb11fa97bbc9c37b4e",
"assets/assets/icons/ic_superchat_homecard.png": "528d27a864e33058903c1351aa7b9576",
"assets/assets/icons/m_super10.png": "a8070b23d8cbf03554dcd7acbc2a03de",
"assets/assets/icons/m_more6.png": "fa841134a761bf34855d9e5827ef1865",
"assets/assets/icons/o.png": "54e2baa2af4a8005f7182a1597f65262",
"assets/assets/icons/m_more2.png": "e92aede94d1e6cf301e101eeee18546b",
"assets/assets/icons/tab_like_selected.png": "768188ab326306a9e8fe0de4d097a701",
"assets/assets/icons/m_profile5.png": "ce88a4a4aea14f7b6958bd92d1713d42",
"assets/assets/icons/m_super2.png": "f219b2e8405c6c1a7533dc76405a1993",
"assets/assets/icons/m_profile6.png": "cde7d709e68c2d1a79c96cdab3b7d295",
"assets/assets/icons/icon_like_sort.png": "3b2569f6548075f6c6331f24c8062f98",
"assets/assets/icons/m_super8.png": "d877668be2b5634072e2f83cdce15e41",
"assets/assets/icons/tab_home_unselected.png": "d19b0c8eb191b4245f3c91a03d0689be",
"assets/assets/icons/gold_crown%25201.png": "90c458f6aef82d0e25b28c25ac7f13cc",
"assets/assets/icons/ic_exchange_before.png": "40020e2315b49a3a2576e05e301faec3",
"assets/assets/icons/logo.png": "34b3b9f86f07d4291f4c282fc85af0f7",
"assets/assets/icons/3.png": "17dabe44ae1f3c1805fcd5ca41d184d7",
"assets/assets/icons/m_more1.png": "5cb0c0da6ebd96b369ed6291fff95886",
"assets/assets/icons/ex.png": "0f43a6947bd91d837a2d8f3fda33d5fd",
"assets/assets/icons/10.png": "4ce62323d9e219de0305c02fedc1a05c",
"assets/assets/icons/VIP_Sliver.png": "07245a1bdbd0b284986d327a36022cf3",
"assets/assets/icons/5.png": "595be62e7df9f753d7cc861dea19e7f5",
"assets/assets/icons/m_more7.png": "9a9f7465f3cd9db6ca34af20487f16bc",
"assets/assets/icons/ic_gift.png": "4531e5b876dc53769dc5467f9959d2b4",
"assets/assets/icons/tab_chat_unselected.png": "3490df948e8c64ffd3a41aa7279f88e1",
"assets/assets/icons/9.png": "eed38749718c0d13c6b59583fe30f99e",
"assets/assets/icons/m_more11.png": "3221d9d934d3b987e2956b0879a09950",
"assets/assets/icons/gold.png": "817fb479be087e8ed2a190fe9f65c74c",
"assets/assets/icons/m_super9.png": "16364893c0c80ca3568ec26fd68d2b04",
"assets/assets/icons/caution.png": "3cf14453dd4418949f4c233c408436b6",
"assets/assets/icons/ic_register_coupon.png": "867378e089c47ff3dafb0ef4ec94d866",
"assets/assets/icons/coupon_input.png": "32704f06b3739e0321bad4bd9eb66e8c",
"assets/assets/icons/profile.png": "fca9bfe4740872d93a38741fb8637c2d",
"assets/assets/icons/google.png": "96c738e1cdecdbebebcfe699255915cd",
"assets/assets/icons/m_profile4.png": "85dfb080f672036a25f75ec6dfde1e8f",
"assets/assets/icons/ic_use_store.png": "a464bc2d63f98b82c4511e50553f0426",
"assets/assets/icons/tab_like_unselected.png": "57413417dd489fc33d1ca9194cd1b905",
"assets/assets/icons/ic_point_store.png": "84d139118a31c122d38a1a5ceceb1312",
"assets/assets/icons/ic_sort_superchat_selected.png": "a2c6de245c49454b64521431b2ec62a1",
"assets/assets/icons/coupon.png": "ff7f3f1e970bffbc9c6938c07a38e5d8",
"assets/assets/icons/m_heart6.png": "fb7322040f9cbc5d1cfd64a0ce37eb2c",
"assets/assets/icons/m_more10.png": "cc58f7946bab71473c16d0649b7104fe",
"assets/assets/icons/like.png": "7ea60e4c5f85d2430bccf19a18fb1bad",
"assets/assets/icons/VIP.png": "3638ab3960c97aba6748d1291f5ef424",
"assets/assets/icons/coins.png": "a6f8368e09c98a5109c20468c35af4eb",
"assets/assets/icons/m_super6.png": "bc6376aa28f0f7dff6caaef74f0a4a2f",
"assets/assets/icons/x.png": "143a5813d29fa13e993a1a03c0f34c90",
"assets/assets/icons/pop.png": "dd7570f95d616d3269cb507fa5409731",
"assets/assets/icons/m_heart2.png": "2247d8f7f717d8c4c4a026b09a3bb962",
"assets/assets/icons/siren.png": "3853351379250c4ba477681d2e27dfca",
"assets/assets/icons/m_heart7.png": "5b4004482b88dad0112770a0452b7700",
"assets/assets/icons/tab_chat_selected.png": "ec8efe84d2be9572fab573d88bedd7dc",
"assets/assets/icons/heart.png": "c595bb469ddeb60bc25012d64a1c7661",
"assets/assets/icons/m_super5.png": "6d39536e65ae409db1c0e423a75f2e93",
"assets/assets/icons/silver.png": "d93032dabee90296523abea915e0efa1",
"assets/assets/icons/vip_sv.svg": "53b9b1b034c2ef671a9b94d1fa30aaa9",
"assets/assets/icons/6.png": "6c432c497298829628e04ee37321fc88",
"assets/assets/icons/m_super1.png": "e806c9947e01418064057c1f973e548e",
"assets/assets/icons/points.png": "e9e65f5881235e2f05d8a338c7c2b93a",
"assets/assets/icons/m_more8.png": "fce6890d6ff601c83b038e10cadb1718",
"assets/assets/icons/bronze.png": "d049b873829d8ab2ec8dbfaf66443513",
"assets/assets/icons/kakao.png": "223581f84e2692c37fd9c8aa2dc4d07f",
"assets/assets/icons/gold_level.png": "0dc9bfed9fa12dc9f75ae6dd85018ab8",
"assets/assets/icons/m_profile3.png": "d13830792e9252bf1cd1f2011e623817",
"assets/assets/icons/m_more3.png": "15443b7bc4a547afde8ade3671c186cc",
"assets/assets/icons/dislike.png": "a21686dd031ccdd8075d33345fdcff79",
"assets/assets/icons/secession.png": "5f69960641c6d85c296f6cc11d21728b",
"assets/assets/icons/1.png": "6f8bd7acb609efee14d268820b12a540",
"assets/assets/icons/2.png": "c0efb69d7e13543429baffeec06ede2b",
"assets/assets/icons/bronze_crown%25201.png": "9590692bc7ea3018d0e37ee4f0a885f9",
"assets/assets/icons/join.png": "2798a23dbc106d19c4f19f6e7c35d464",
"assets/assets/icons/m_heart4.png": "05eb0dfbb25c53529bb41bcc3f4e6f31",
"assets/assets/icons/vip_buy.png": "f6afda8f3f19abbcb544b15cc7e25fe2",
"assets/assets/icons/8.png": "bf57f6eaf35defdc88859916b8cf125a",
"assets/assets/icons/check.png": "d265951cc5dfead7888657ef72e16dca",
"assets/assets/icons/7.png": "1344919d0a33cfdf6d6cd2e37c0da5cb",
"assets/assets/icons/VIP_Gold.png": "973ca875a0f4c04674c628b2d24581eb",
"assets/assets/icons/point.png": "c109244012201e9d9ee0443e2bdd1319",
"assets/assets/icons/tab_home_selected.png": "08891f653dd399e5614e89d7ee1630a6",
"assets/assets/icons/m_super7.png": "a7421b8fa61abfe118d86526178b6e25",
"assets/assets/icons/ic_setting_sort.png": "a672dd6534b85d3bfe0d80c1f77acbe9",
"assets/assets/icons/ic_verified.png": "3c8428e989d2fe5ef11e097129434b35",
"assets/assets/icons/silver_crown%25201.png": "b401a26de2c6a7c1c3d87d3316f52830",
"assets/assets/icons/m_profile9.png": "0da4fba9fb3daee53fcb9b0299fc4742",
"assets/assets/icons/coin.png": "4f53142661481e406a87be73e32da450",
"assets/assets/icons/m_super4.png": "b29e8d02f287addcd5af7b9e1ae8528e",
"assets/assets/icons/superchat.png": "04fbd2ac56ec43340f634ca098db56e6",
"assets/assets/icons/chat.png": "9cb174d50866e637ceb812921f60caad",
"assets/assets/icons/invit.png": "4e5ee00e12a38e6cb6bd3e7a231b748d",
"assets/assets/icons/certi%25201.png": "50ffc86653bbaa3836c5148e82b220d7",
"assets/assets/icons/VIP%2520Frame.png": "4abbdc592ed32f2a7ecbb7336c5948e6",
"assets/assets/icons/ic_exchange_after.png": "e4f8600ffc6630be1512d5171c2c3fc6",
"assets/assets/icons/m_more4.png": "fa4fa236db16133a9d9ddf8af9e77e86",
"assets/assets/icons/m_heart1.png": "9502c9f8450b44cda298369dd075e3ce",
"assets/assets/icons/ic_close_homecard.png": "1b424714d50483ea2d612d47e84501e0",
"assets/assets/icons/m_more5.png": "fa841134a761bf34855d9e5827ef1865",
"assets/assets/icons/m_heart9.png": "98f89365d0d029979688b03dac0ae5d5",
"assets/assets/icons/ic_sort_like.png": "dcb3cb130a42e372a6278db5462dd7c1",
"assets/assets/icons/m_profile2.png": "111959acff1fe744f7a7bf55d77a1b34",
"assets/assets/icons/3.0x/ic_vip_home.png": "d863ce5aedf91972aff3cf3a1e8f388e",
"assets/assets/icons/3.0x/ic_polygon_exchange.png": "f3dbb5a87c04ec876aa272d9fa628fcb",
"assets/assets/icons/3.0x/4.png": "d90dc733603dfb7fb5ed8a803ed89c21",
"assets/assets/icons/3.0x/ic_exchange_point.png": "9d1b8385c7323dfd284713bd22d9e551",
"assets/assets/icons/3.0x/ic_sort_superchat.png": "c31d120293f1a9b39ca36058a716eba4",
"assets/assets/icons/3.0x/icon_like_superchat.png": "4dd4ee7d7f3ff1f1011ad7f1930b67a8",
"assets/assets/icons/3.0x/ic_superchat_homecard.png": "459223d01c4db6b2d94aa37b497c0eac",
"assets/assets/icons/3.0x/tab_like_selected.png": "ee1ef682dec86c7c8f9053c144a05cb7",
"assets/assets/icons/3.0x/icon_like_sort.png": "530d0759f08963fe17e419f5c4a6db44",
"assets/assets/icons/3.0x/tab_home_unselected.png": "bd56b93210a24196d86510e1e6b3d875",
"assets/assets/icons/3.0x/ic_exchange_before.png": "e42f1ec1531cc6ebf16f5b297578ba14",
"assets/assets/icons/3.0x/3.png": "870967d4f498e9236c6eee0170b43b9c",
"assets/assets/icons/3.0x/10.png": "e16de0e363206705e0dddf3a43f02e59",
"assets/assets/icons/3.0x/5.png": "10db507786a264c8280c86cc79500bb1",
"assets/assets/icons/3.0x/ic_gift.png": "e8e77fc41535b55dc82b628b22c1846f",
"assets/assets/icons/3.0x/tab_chat_unselected.png": "4b1723ebc67d8707dd4f53a213b6a0fc",
"assets/assets/icons/3.0x/9.png": "3048eda6989f9c33d5f59f63e1948ecb",
"assets/assets/icons/3.0x/ic_register_coupon.png": "9f4b27af81c0f88a32abaa522f46f583",
"assets/assets/icons/3.0x/ic_use_store.png": "ca8710ce93c31f83078ce16eea27bf1c",
"assets/assets/icons/3.0x/tab_like_unselected.png": "0e99d112dd32f76c0c872cee6ab18efe",
"assets/assets/icons/3.0x/ic_point_store.png": "acba0bfa427ec962a98f62aaca185f3d",
"assets/assets/icons/3.0x/ic_sort_superchat_selected.png": "4b85c86121fca961e4749d8f31c1de25",
"assets/assets/icons/3.0x/tab_chat_selected.png": "c8e5d1cb1892c58622a6ec2391883527",
"assets/assets/icons/3.0x/6.png": "fbc1209510d62f4b31ae1a4779e44496",
"assets/assets/icons/3.0x/1.png": "e1723d386f7cf768a1b31cfa1317e98e",
"assets/assets/icons/3.0x/2.png": "53020aca2d0079d4c91490b4bebb0780",
"assets/assets/icons/3.0x/8.png": "99225840f92bcaf01137ca5ef214323d",
"assets/assets/icons/3.0x/7.png": "2944c6ee1d915d122f9a05ccaf78c36e",
"assets/assets/icons/3.0x/tab_home_selected.png": "710ea970c717e3b0647b3e9d64a3add1",
"assets/assets/icons/3.0x/ic_setting_sort.png": "bc3f28b13c5b621e13f380c16473d754",
"assets/assets/icons/3.0x/ic_verified.png": "80f2a110054409afbbb804104ed8cef2",
"assets/assets/icons/3.0x/ic_exchange_after.png": "c5f973af802b56de63665918532e538e",
"assets/assets/icons/3.0x/ic_close_homecard.png": "66a77b41b351ae112a1a7cbe60249db8",
"assets/assets/icons/3.0x/ic_sort_like.png": "07fdac0d4ad3ae1b0581566050d7a572",
"assets/assets/icons/3.0x/ic_sort_like_selected.png": "f7f81a327fc7a5c4256a2737829dac4c",
"assets/assets/icons/3.0x/ic_like_homecard.png": "79ccc2d6576d3ff6cc209b6c5b3cd4d7",
"assets/assets/icons/naver.png": "21ba0efe88b4126e2d5c2518f0e9eb0f",
"assets/assets/icons/ic_sort_like_selected.png": "ab6391c4cd2d4a506f69ac4f1845ebd0",
"assets/assets/icons/m_heart8.png": "3aff26fafb7583425c458731ac22c46f",
"assets/assets/icons/2.0x/ic_vip_home.png": "1e211ba421c8bc6693abff98256fdf2d",
"assets/assets/icons/2.0x/ic_polygon_exchange.png": "a001204a3c75eea92af1129c7fba20fd",
"assets/assets/icons/2.0x/4.png": "2060b2bc523316cffbc06d889a45ee6e",
"assets/assets/icons/2.0x/ic_exchange_point.png": "fcd7081742df369287004c833200656c",
"assets/assets/icons/2.0x/ic_sort_superchat.png": "cb31319a86596d2dc8b7f9a33c956c5d",
"assets/assets/icons/2.0x/icon_like_superchat.png": "1a5cb2e6bba9b2611a532de80bdfe825",
"assets/assets/icons/2.0x/ic_superchat_homecard.png": "889495aa86e6f18630c77fe82d97ee60",
"assets/assets/icons/2.0x/tab_like_selected.png": "ed69296bfc68773bc6ebc90dc89bd8e3",
"assets/assets/icons/2.0x/icon_like_sort.png": "70d4293ae2723e91d85c843c373df9e3",
"assets/assets/icons/2.0x/tab_home_unselected.png": "bb7b36b944682d5eff231ee3ed0f10e5",
"assets/assets/icons/2.0x/ic_exchange_before.png": "da5bb076b213930cab0d6e970bd969d5",
"assets/assets/icons/2.0x/3.png": "80208706a146405a8758c54ce54d6335",
"assets/assets/icons/2.0x/10.png": "823fbfef8efea5a42ec56c76cd9efa96",
"assets/assets/icons/2.0x/5.png": "c2d15f32d046a11def80d59e15e94b46",
"assets/assets/icons/2.0x/ic_gift.png": "f502d7ce1e3ea46aed80eed07c5bbd47",
"assets/assets/icons/2.0x/tab_chat_unselected.png": "fe4123d464f692e73d64dd009239b39d",
"assets/assets/icons/2.0x/9.png": "a21464f978cc149b756b69b6c2300344",
"assets/assets/icons/2.0x/ic_register_coupon.png": "1ef883301f7fabd183178ed0ff96d7b0",
"assets/assets/icons/2.0x/ic_use_store.png": "701f64f99cf8e116d50cdb3df8509209",
"assets/assets/icons/2.0x/tab_like_unselected.png": "a27c36c427c161d3291b4524a988fd04",
"assets/assets/icons/2.0x/ic_point_store.png": "d3172050fcfadf49c3054c675921a6bc",
"assets/assets/icons/2.0x/ic_sort_superchat_selected.png": "7c6a6f7a293b48ae58488d0c50df5525",
"assets/assets/icons/2.0x/tab_chat_selected.png": "04ad87d4cb52f316fe5e17c1e79251de",
"assets/assets/icons/2.0x/6.png": "bef05b4808dae057f2eb0da5e7230750",
"assets/assets/icons/2.0x/1.png": "1ebdfd261c36d741e645914752bde88b",
"assets/assets/icons/2.0x/2.png": "5f9344d9f10a5583e32ea6d60ae17ffa",
"assets/assets/icons/2.0x/8.png": "11d4a10271539cb30d243f39a27e362a",
"assets/assets/icons/2.0x/7.png": "a63ae9c1b1eb950968d3aaccc5a83766",
"assets/assets/icons/2.0x/tab_home_selected.png": "22ecf18e0149c5610c585e857e2243c7",
"assets/assets/icons/2.0x/ic_setting_sort.png": "2979e589101ce9195d4235788341d5ae",
"assets/assets/icons/2.0x/ic_verified.png": "52ea03701a1d3f11cec7e486eb2a7e2a",
"assets/assets/icons/2.0x/ic_exchange_after.png": "345a7d94d5a115af10877139f35b80dc",
"assets/assets/icons/2.0x/ic_close_homecard.png": "e95d1105de3c722992e6e3d60f43f330",
"assets/assets/icons/2.0x/ic_sort_like.png": "1350edd66293f2a1d4bcfbcefdd6152b",
"assets/assets/icons/2.0x/ic_sort_like_selected.png": "15c3d8f2c7cdc77de9ff71ee16a4ef04",
"assets/assets/icons/2.0x/ic_like_homecard.png": "c0e439865ea61ceef883cc5d1391fb04",
"assets/assets/icons/ic_like_homecard.png": "935ce2d6933c4ab7cb9f763c97b42cb7",
"assets/assets/icons/m_profile11.png": "68c13a347e39032c8ed2de98a804c34b",
"assets/assets/vip/B45.png": "3f8bd6efe6ce1539768c53da472971ae",
"assets/assets/vip/Sliver_flame.png": "7c02dbb2474f99650199c4a2abe056f4",
"assets/assets/vip/B20.png": "5b4735ff137ef15eeba561c551840d12",
"assets/assets/vip/B30.png": "4e0f8acea594022e0c5e69f251fac522",
"assets/assets/vip/G7.png": "52001e8d84c882daec5c59307963e93d",
"assets/assets/vip/B_silver.png": "2b1d64c7fd311e4387dfca059324e609",
"assets/assets/vip/B_bronze.png": "a29f0ac32cb7b65389bccd9c46d31dcf",
"assets/assets/vip/S45.png": "230f8419fe77be9182b6ae8161cfcde5",
"assets/assets/vip/B60.png": "0b46ef93c4ac5234f9100889ed42a4f2",
"assets/assets/vip/BS_gold.png": "afdbb72d8705f54aa43338bfc12b10e5",
"assets/assets/vip/S30.png": "6d08f7f732136c6155ab40c571b8bcf6",
"assets/assets/vip/S15.png": "759b23186d0046826aa4067b33836801",
"assets/assets/vip/BS_silver.png": "57db61bd4123e4dfcb37b492f0720a63",
"assets/assets/vip/bronze_level.png": "e47720b7a98f8ebb11fa97bbc9c37b4e",
"assets/assets/vip/G15.png": "c85e444df16bf59f5aea279c4c9a9895",
"assets/assets/vip/G60.png": "576e7eb6ad39256d51b7ff53bd2e61e2",
"assets/assets/vip/BS_bronze.png": "bab05c7a239652ffde73d40317c772e1",
"assets/assets/vip/B15.png": "d1ffcddbc5532961f6279413c2a1e2e2",
"assets/assets/vip/G30.png": "453c93bd329cbaf96978d75d45076363",
"assets/assets/vip/Bronze_flame.png": "49c684c84474a0c2458a0358c3346eb2",
"assets/assets/vip/silver_level.png": "07245a1bdbd0b284986d327a36022cf3",
"assets/assets/vip/gold_level.png": "f1e339b6d1ea77dc2e64fed7aa17123e",
"assets/assets/vip/S7.png": "d425cd1dcd79c2c72962a88f350fbaac",
"assets/assets/vip/B7.png": "1fd185235f7b82897317a9ac53ec5d7e",
"assets/assets/vip/S60.png": "04057d9d120d80fabb00266e5f5768fc",
"assets/assets/vip/S20.png": "aa46f1c34b82ff31d156df17a16f5a04",
"assets/assets/vip/Gold_flame.png": "b1b3f58e4a08efae3b5379818e3d1509",
"assets/assets/vip/G20.png": "70d1b562c85217cd4c83615a23ce7b34",
"assets/assets/vip/G45.png": "08e3addf3a54a196179b35f3a0295322",
"assets/assets/vip/no_level.png": "701ca16270644b201cbbe11bd0a12643",
"assets/assets/splash/SPLASH@3x.png": "1d624f3e3ddef2ed03da79ca5ccf611d",
"assets/assets/html/mok.html": "53db7a19f3b1e58d20459e9644964e68",
"assets/assets/html/mok_simple.html": "91a3e15801a8cf752556e7bb502977ae",
"assets/assets/images/Tutorial%25205.png": "954ace19be5a1afab45ec06a91d965cc",
"assets/assets/images/Tutorial%25203.png": "36f73a3645f349f0e0b2decc48e4d7aa",
"assets/assets/images/guide.png": "e5f0b92531d56197a67d2baf2127e7db",
"assets/assets/images/Tutorial%25202.png": "43f8c7122f5dc363d68b3ee2ff8b8a2b",
"assets/assets/images/Tutorial%25201.png": "d85eba6e526c298c9cfb54a780fb36bf",
"assets/assets/images/Tutorial%25204.png": "b19333b118597c511614c41437f8e7a6",
"assets/assets/images/tutorial_background.png": "242c8662c334c6243d025bba72f68d0e",
"assets/assets/images/profile_guide.png": "b74f6353b14b89f1f61b0fc192749c20",
"assets/assets/images/Tutorial%25206.png": "0133b0fb838f8b215b93d7b5b841eed3",
"assets/assets/images/3.0x/Tutorial%25205.png": "cce4d12abf7aee6ea135e04606031efc",
"assets/assets/images/3.0x/Tutorial%25203.png": "9f8ea5c6a052bec22486aa7cb9b9c869",
"assets/assets/images/3.0x/Tutorial%25202.png": "d13fc60ca6911907c7df5cf6ed7382c9",
"assets/assets/images/3.0x/Tutorial%25201.png": "df5f7489ccb4470e7db5a438eb96e6dd",
"assets/assets/images/3.0x/Tutorial%25204.png": "6ebfce08bf5e2bc518ee9e7e2e76acd0",
"assets/assets/images/3.0x/tutorial_background.png": "6e82e0991df1824c3ea9ac6ae0b60eec",
"assets/assets/images/3.0x/Tutorial%25206.png": "401f5652886f6770bc84c9cb0d4b852e",
"assets/assets/images/2.0x/Tutorial%25205.png": "de2f03df921aa68ec913ffb1f272e87f",
"assets/assets/images/2.0x/Tutorial%25203.png": "12cd313f598a058ea4dc9ad5c020dc5b",
"assets/assets/images/2.0x/Tutorial%25202.png": "15177767cce937d47ce86e0cbf7d2107",
"assets/assets/images/2.0x/Tutorial%25201.png": "c024ccbe2724d69f7e05307d21a50428",
"assets/assets/images/2.0x/Tutorial%25204.png": "286daca6ee54f67cc6de24468d799b52",
"assets/assets/images/2.0x/tutorial_background.png": "81a6bdec2679e408a9b203807646ce32",
"assets/assets/images/2.0x/Tutorial%25206.png": "b7104b6035a9cde7d9261ebdf2161728",
"assets/assets/point/4.png": "402de09fd981a83abcbe13adf46d70d2",
"assets/assets/point/3.png": "e21beaac56e9fa6101fdeddf2aafd9e6",
"assets/assets/point/10.png": "f425db1c2a0b4d7db767617593a7338f",
"assets/assets/point/5.png": "273d40d9b706e49d9c1c47b9a1ae8280",
"assets/assets/point/9.png": "f425db1c2a0b4d7db767617593a7338f",
"assets/assets/point/12.png": "f425db1c2a0b4d7db767617593a7338f",
"assets/assets/point/11.png": "f425db1c2a0b4d7db767617593a7338f",
"assets/assets/point/6.png": "f425db1c2a0b4d7db767617593a7338f",
"assets/assets/point/1.png": "b71a523437f2ee5ae0fe717ab088bd75",
"assets/assets/point/2.png": "b98da0dc29e9246892ad1723db75a661",
"assets/assets/point/8.png": "f425db1c2a0b4d7db767617593a7338f",
"assets/assets/point/7.png": "f425db1c2a0b4d7db767617593a7338f",
"assets/FontManifest.json": "bef31c72274963524f3768ac0ea586c7",
"assets/AssetManifest.bin.json": "2108b9a7a031b05aaee0305da0cb8b72",
"assets/AssetManifest.bin": "f526cb986b1fe831b81f5c43882f1750",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/amplify_auth_cognito_dart/lib/src/workers/workers.min.js.map": "d206bb2fe388804514ce79faaf0ed556",
"assets/packages/amplify_auth_cognito_dart/lib/src/workers/workers.min.js": "de4cf86bb47ae06dfe769b8d1ceaf0ec",
"assets/packages/amplify_secure_storage_dart/lib/src/worker/workers.min.js.map": "2f12c73918f19834376b0e123ef4c723",
"assets/packages/amplify_secure_storage_dart/lib/src/worker/workers.min.js": "9a2b99dd0e5f96670060b4887b9e8c30",
"assets/packages/naver_login_sdk/assets/kr/white/btn_rectangle_icon.png": "a2160e13ae5e36cd094d7bd6fc8968db",
"assets/packages/naver_login_sdk/assets/kr/white/btn_circle_icon.png": "c1d70510d82d1c7af791d22087676e12",
"assets/packages/naver_login_sdk/assets/kr/white/btn_rectangle_with_naver.png": "5c3d65b6f1ea4d84d36b50d7e2010005",
"assets/packages/naver_login_sdk/assets/kr/white/btn_rectangle.png": "bafc7c5d88c15253cf0afd44b208125e",
"assets/packages/naver_login_sdk/assets/kr/green/btn_rectangle_icon.png": "9b8bbec2b446ff566ce2df35bc2d7905",
"assets/packages/naver_login_sdk/assets/kr/green/btn_circle_icon.png": "0160f7aeec6f09c56c59902343d87017",
"assets/packages/naver_login_sdk/assets/kr/green/btn_rectangle_with_naver.png": "e010167225dc8c81448178373513a1c6",
"assets/packages/naver_login_sdk/assets/kr/green/btn_rectangle.png": "3b5058a2b7d36e043ea53b7d2df3cc91",
"assets/packages/naver_login_sdk/assets/kr/dark/btn_rectangle_icon.png": "63678c5ab835157f4c539d95e2bbdbf1",
"assets/packages/naver_login_sdk/assets/kr/dark/btn_circle_icon.png": "ca8587c9d313fb286180ff80dcce7746",
"assets/packages/naver_login_sdk/assets/kr/dark/btn_rectangle_with_naver.png": "f86bac66ab887ba6ed12422f41c0635b",
"assets/packages/naver_login_sdk/assets/kr/dark/btn_rectangle.png": "39a7e0ad332c4ce23dbe2d65056624d8",
"assets/packages/naver_login_sdk/assets/kr/logout/btn_logout_green.png": "a781cf26940ce82bde4203a90a03250e",
"assets/packages/naver_login_sdk/assets/kr/logout/btn_logout_dark.png": "044dc7cc540e5fd6e92381ef2e0c0b53",
"assets/packages/naver_login_sdk/assets/kr/logout/btn_logout_white.png": "524721aebbc644fcff24d87ab95e349e",
"assets/packages/naver_login_sdk/assets/en/white/btn_rectangle_icon.png": "a2160e13ae5e36cd094d7bd6fc8968db",
"assets/packages/naver_login_sdk/assets/en/white/btn_circle_icon.png": "c1d70510d82d1c7af791d22087676e12",
"assets/packages/naver_login_sdk/assets/en/white/btn_rectangle_with_naver.png": "65eb2674d27cd8e3238e9b1b33932b89",
"assets/packages/naver_login_sdk/assets/en/white/btn_rectangle.png": "285c79cff0b69428bc956fac8748c049",
"assets/packages/naver_login_sdk/assets/en/green/btn_rectangle_icon.png": "9b8bbec2b446ff566ce2df35bc2d7905",
"assets/packages/naver_login_sdk/assets/en/green/btn_circle_icon.png": "0160f7aeec6f09c56c59902343d87017",
"assets/packages/naver_login_sdk/assets/en/green/btn_rectangle_with_naver.png": "97925a54cff6cafa5578f4e56303a659",
"assets/packages/naver_login_sdk/assets/en/green/btn_rectangle.png": "7803c96fca6999fba1b1a620effc1105",
"assets/packages/naver_login_sdk/assets/en/dark/btn_rectangle_icon.png": "63678c5ab835157f4c539d95e2bbdbf1",
"assets/packages/naver_login_sdk/assets/en/dark/btn_circle_icon.png": "ca8587c9d313fb286180ff80dcce7746",
"assets/packages/naver_login_sdk/assets/en/dark/btn_rectangle_with_naver.png": "246fa3b886575bc219a24f58cd2c0e76",
"assets/packages/naver_login_sdk/assets/en/dark/btn_rectangle.png": "96b682fab3f0ba6f7530cb07d4d30fdc",
"assets/packages/naver_login_sdk/assets/en/logout/btn_logout_green.png": "fa974a150494a8091a6674092b486df2",
"assets/packages/naver_login_sdk/assets/en/logout/btn_logout_dark.png": "0af1aea96159497291755c21f53fd66e",
"assets/packages/naver_login_sdk/assets/en/logout/btn_logout_white.png": "60f8ee4b29c6a2ccf1b906b7a45dd624",
"flutter_bootstrap.js": "092f423aec434e9470de9e4a4079c3b6",
"admin_index.html": "4ee312a16333685af420913273e28908",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"index.html": "c40d63c3e02d8d92121c169a96560273",
"/": "c40d63c3e02d8d92121c169a96560273"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
