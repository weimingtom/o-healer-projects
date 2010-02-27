package{
	public class MyFont{
		[Embed(
			source='mplus-1m-medium.ttf',
			fontName='system',
			unicodeRange='U+9699,U+5404,U+5831,U+51fa,U+7d76,U+517c,U+666e,U+8aac,U+8a31,U+7acb,U+5217,U+666f,U+5fa1,U+5834,U+8a2d,U+884c,U+767b,U+5b8c,U+5408,U+4f1d,U+66f4,U+6295,U+5f71,U+7e2e,U+767d,U+6297,U+5185,U+305a,U+300c,U+5186,U+6d41,U+30da,U+300d,U+8ee2,U+6bce,U+672a,U+7684,U+305b,U+66f8,U+6301,U+4a,U+30dc,U+30e0,U+3060,U+691c,U+610f,U+6bd4,U+30dd,U+672c,U+30e1,U+4b,U+305d,U+3061,U+5fa9,U+305e,U+30de,U+4c,U+50,U+5370,U+30e2,U+30df,U+4d,U+53f0,U+305f,U+51,U+3063,U+904e,U+5c01,U+30e3,U+6163,U+4e,U+7121,U+52,U+3064,U+63cf,U+5c02,U+6307,U+30e4,U+4f,U+9006,U+53,U+96a3,U+9054,U+50cf,U+53ef,U+30e5,U+54,U+3066,U+754c,U+985e,U+53f3,U+55,U+3067,U+9055,U+7d50,U+30e7,U+56,U+3068,U+79fb,U+5c06,U+7126,U+4e8b,U+57,U+3069,U+7d9a,U+30e9,U+58,U+7dd2,U+8584,U+5e8f,U+53f7,U+59,U+5e45,U+53f8,U+89e6,U+6c17,U+6841,U+2190,U+6271,U+2191,U+958b,U+547c,U+56f0,U+2192,U+6607,U+2193,U+ff1a,U+56f2,U+7a7a,U+68c4,U+7a2e,U+97ff,U+64e6,U+ff21,U+9593,U+5165,U+4f4d,U+4f4e,U+6b7b,U+7a81,U+5f53,U+30ba,U+ff1f,U+6b32,U+ff23,U+6469,U+51e6,U+30bb,U+72b6,U+ff24,U+308a,U+5168,U+2a,U+4f53,U+5de6,U+8a18,U+30bd,U+591a,U+534a,U+ff25,U+308b,U+30c0,U+2b,U+8a66,U+4f55,U+308c,U+30c1,U+2c,U+30,U+6bb5,U+3042,U+69cb,U+ff27,U+7a,U+308d,U+30bf,U+2d,U+31,U+5730,U+53cd,U+57fa,U+7b,U+6570,U+30c3,U+632f,U+2e,U+32,U+3044,U+30c4,U+53ce,U+7c,U+3092,U+2f,U+33,U+9650,U+964d,U+7d,U+308f,U+969b,U+3093,U+34,U+3046,U+65a5,U+675f,U+30c6,U+35,U+6574,U+30c7,U+36,U+3048,U+6765,U+4ea1,U+37,U+7d30,U+30c8,U+898b,U+5357,U+53d6,U+5974,U+30c9,U+38,U+5927,U+8fd1,U+53d7,U+39,U+5ea6,U+6cc1,U+69d8,U+4eee,U+7bc4,U+5ea7,U+7f6e,U+898f,U+6c42,U+540c,U+8fd4,U+624b,U+540d,U+5411,U+521d,U+52a0,U+6253,U+7bc9,U+8003,U+5224,U+80cc,U+7b49,U+9332,U+7b97,U+54e1,U+95a2,U+58c1,U+629e,U+5272,U+5143,U+7070,U+518d,U+5b9a,U+5f31,U+88dc,U+66ff,U+975e,U+9762,U+ff01,U+885d,U+5145,U+5f80,U+7406,U+8a8d,U+ff03,U+8abf,U+7834,U+5468,U+5148,U+306a,U+5b9f,U+9577,U+30ea,U+306b,U+6b63,U+5f37,U+5897,U+5b57,U+30eb,U+ff06,U+4f7f,U+5f85,U+63db,U+5b58,U+30ec,U+5a,U+3070,U+30a2,U+306d,U+3071,U+30a3,U+7269,U+611f,U+8868,U+500d,U+30ed,U+ff08,U+5b,U+900f,U+5012,U+4f38,U+59cb,U+ff09,U+306e,U+3072,U+30a4,U+3073,U+616e,U+5d,U+306f,U+61,U+5e,U+5c11,U+30f3,U+62,U+30a6,U+793a,U+5c0f,U+30a7,U+6a2a,U+5f,U+63,U+4e00,U+64,U+3076,U+30a8,U+4eca,U+8d8a,U+7dda,U+7ba1,U+65,U+30a9,U+6319,U+3078,U+9,U+6557,U+66,U+67,U+3079,U+9685,U+6ca2,U+68,U+5909,U+9069,U+8ffd,U+69,U+90e8,U+524a,U+89a7,U+4e08,U+660e,U+516b,U+529b,U+64ec,U+524d,U+4e57,U+58eb,U+4ed8,U+5206,U+5207,U+5171,U+60c5,U+627f,U+62b5,U+68d2,U+5f0f,U+80fd,U+8272,U+52d5,U+5fdc,U+7cfb,U+4f5c,U+ff30,U+826f,U+8c61,U+8a72,U+5f15,U+5dee,U+5bfe,U+5f62,U+ff2d,U+ff31,U+7a3f,U+3000,U+76ee,U+6b8a,U+52d8,U+4fe1,U+6b8b,U+304a,U+ff32,U+3001,U+30ca,U+4fdd,U+30cb,U+304b,U+ff33,U+3002,U+614b,U+7248,U+671b,U+3050,U+ff34,U+30d0,U+3a,U+304c,U+3051,U+5bb9,U+7e26,U+30cd,U+3b,U+304d,U+3005,U+65ad,U+ff36,U+67a0,U+65b0,U+30d1,U+3c,U+592b,U+304e,U+30cf,U+3053,U+ff37,U+30d2,U+3d,U+304f,U+41,U+9802,U+5f69,U+30d3,U+5931,U+76f8,U+671f,U+3e,U+42,U+6771,U+3b1,U+63c3,U+3055,U+753b,U+30d4,U+3f,U+592e,U+43,U+3056,U+984d,U+5316,U+6392,U+77ac,U+30d5,U+44,U+5317,U+899a,U+9805,U+30d6,U+45,U+3057,U+96e2,U+9806,U+4e2d,U+30d7,U+6d88,U+46,U+3058,U+9664,U+47,U+3059,U+89d2,U+79f0,U+30d9,U+6349,U+4efb,U+48,U+8907,U+6587,U+65b9,U+7d42,U+49,U+6210,U+7b54,U+6a5f,U+7167,U+8def,U+5e38,U+5099,U+56db,U+914d,U+64cd,U+62e1,U+91cd,U+8d77,U+4e86,U+6a19,U+6642,U+60f3,U+78ba,U+91cf,U+6027,U+843d,U+4e88,U+56de,U+72ec,U+5236,U+ff0b,U+8eab,U+72ed,U+7e01,U+7d99,U+ff10,U+4f3c,U+ff0d,U+ff11,U+5f8c,U+5fc3,U+4f8b,U+30aa,U+6b21,U+30ab,U+52b9,U+ff5c,U+a,U+ff13,U+901a,U+30ac,U+6697,U+ff14,U+4fc3,U+5fc5,U+ff15,U+307b,U+5b66,U+30ad,U+30b0,U+6700,U+ff5e,U+8a08,U+53bb,U+307c,U+70b9,U+30b1,U+20,U+d,U+30fb,U+63a1,U+30af,U+30b2,U+21,U+30fc,U+6a,U+63a2,U+631f,U+3081,U+30b3,U+7279,U+22,U+6b,U+307d,U+5f97,U+9023,U+901f,U+3082,U+30b4,U+23,U+6c,U+307e,U+81ea,U+70,U+4e0a,U+982d,U+71,U+30b5,U+53c2,U+756a,U+571f,U+6d,U+307f,U+4e0b,U+3083,U+25,U+5024,U+6e,U+72,U+3084,U+63a5,U+4e0d,U+61b6,U+8fba,U+30b7,U+26,U+6f,U+73,U+7d20,U+5916,U+30b8,U+6708,U+27,U+6e1b,U+751f,U+74,U+8fbc,U+5727,U+5074,U+30b9,U+28,U+75,U+968e,U+6709,U+6c7a,U+73fe,U+29,U+5728,U+8981,U+76,U+3088,U+7d71,U+8d05,U+79d2,U+9077,U+77,U+3089,U+897f,U+9078,U+65e8,U+78,U+623b,U+4ee3,U+7528,U+79,U+6620,U+77e5,U+6240,U+62bc,U+8986,U+7387,U+4ee5,'
		)]
		private var GameFont:Class
	}
}
