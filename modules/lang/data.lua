local translit_title_table = {
	['ahl'] = {
		['default'] = 'Academy of the Hebrew Language transliteration',
		},

	['ala'] = {
		['default'] = 'American Library Association – Library of Congress transliteration',
		},

	['ala-lc'] = {
		['default'] = 'American Library Association – Library of Congress transliteration',
		},

	['batr'] = {
		['default'] = 'Bikdash Arabic Transliteration Rules',
		},

	['bgn/pcgn'] = {
		['default'] = 'Board on Geographic Names / Permanent Committee on Geographical Names transliteration',
		},

	['din'] = {
		['ar'] = 'DIN 31635 Arabic',
		['fa'] = 'DIN 31635 Arabic',
		['ku'] = 'DIN 31635 Arabic',
		['ps'] = 'DIN 31635 Arabic',
		['tg'] = 'DIN 31635 Arabic',
		['ug'] = 'DIN 31635 Arabic',
		['ur'] = 'DIN 31635 Arabic',
		['arab'] = 'DIN 31635 Arabic',

		['default'] = 'DIN transliteration',
		},

	['eae'] = {
		['default'] = 'Encyclopaedia Aethiopica transliteration',
		},

	['hepburn'] = {
		['default'] = 'Hepburn transliteration',
		},

	['hunterian'] = {
		['default'] = 'Hunterian transliteration',
		},

	['iast'] = {
		['default'] = 'International Alphabet of Sanskrit transliteration',
		},

	['iso'] = {																	-- when a transliteration standard is supplied
		['ab'] = 'ISO 9 Cyrillic',
		['ba'] = 'ISO 9 Cyrillic',
		['be'] = 'ISO 9 Cyrillic',
		['bg'] = 'ISO 9 Cyrillic',
		['kk'] = 'ISO 9 Cyrillic',
		['ky'] = 'ISO 9 Cyrillic',
		['mn'] = 'ISO 9 Cyrillic',
		['ru'] = 'ISO 9 Cyrillic',
		['tg'] = 'ISO 9 Cyrillic',
		['uk'] = 'ISO 9 Cyrillic',
		['bua'] = 'ISO 9 Cyrillic',
		['sah'] = 'ISO 9 Cyrillic',
		['tut'] = 'ISO 9 Cyrillic',
		['xal'] = 'ISO 9 Cyrillic',
		['cyrl'] = 'ISO 9 Cyrillic',

		['ar'] = 'ISO 233 Arabic',
		['ku'] = 'ISO 233 Arabic',
		['ps'] = 'ISO 233 Arabic',
		['ug'] = 'ISO 233 Arabic',
		['ur'] = 'ISO 233 Arabic',
		['arab'] = 'ISO 233 Arabic',

		['he'] = 'ISO 259 Hebrew',
		['yi'] = 'ISO 259 Hebrew',
		['hebr'] = 'ISO 259 Hebrew',

		['el'] = 'ISO 843 Greek',
		['grc'] = 'ISO 843 Greek',

		['ja'] = 'ISO 3602 Japanese',
		['hira'] = 'ISO 3602 Japanese',
		['hrkt'] = 'ISO 3602 Japanese',
		['jpan'] = 'ISO 3602 Japanese',
		['kana'] = 'ISO 3602 Japanese',

		['zh'] = 'ISO 7098 Chinese',
		['chi'] = 'ISO 7098 Chinese',
		['pny'] = 'ISO 7098 Chinese',
		['zho'] = 'ISO 7098 Chinese',
--		['han'] = 'ISO 7098 Chinese',											-- unicode alias of Hani? doesn't belong here? should be Hani?
		['hans'] = 'ISO 7098 Chinese',
		['hant'] = 'ISO 7098 Chinese',

		['ka'] = 'ISO 9984 Georgian',
		['kat'] = 'ISO 9984 Georgian',

		['arm'] = 'ISO 9985 Armenian',
		['hy'] = 'ISO 9985 Armenian',

		['th'] = 'ISO 11940 Thai',
		['tha'] = 'ISO 11940 Thai',

		['ko'] = 'ISO 11941 Korean',
		['kor'] = 'ISO 11941 Korean',

		['awa'] = 'ISO 15919 Indic',
		['bho'] = 'ISO 15919 Indic',
		['bn'] = 'ISO 15919 Indic',
		['bra'] = 'ISO 15919 Indic',
		['doi'] = 'ISO 15919 Indic',
		['dra'] = 'ISO 15919 Indic',
		['gon'] = 'ISO 15919 Indic',
		['gu'] = 'ISO 15919 Indic',
		['hi'] = 'ISO 15919 Indic',
		['hno'] = 'ISO 15919 Indic',
		['inc'] = 'ISO 15919 Indic',
		['kn'] = 'ISO 15919 Indic',
		['kok'] = 'ISO 15919 Indic',
		['ks'] = 'ISO 15919 Indic',
		['mag'] = 'ISO 15919 Indic',
		['mai'] = 'ISO 15919 Indic',
		['ml'] = 'ISO 15919 Indic',
		['mr'] = 'ISO 15919 Indic',
		['ne'] = 'ISO 15919 Indic',
		['new'] = 'ISO 15919 Indic',
		['or'] = 'ISO 15919 Indic',
		['pa'] = 'ISO 15919 Indic',
		['pnb'] = 'ISO 15919 Indic',
		['raj'] = 'ISO 15919 Indic',
		['sa'] = 'ISO 15919 Indic',
		['sat'] = 'ISO 15919 Indic',
		['sd'] = 'ISO 15919 Indic',
		['si'] = 'ISO 15919 Indic',
		['skr'] = 'ISO 15919 Indic',
		['ta'] = 'ISO 15919 Indic',
		['tcy'] = 'ISO 15919 Indic',
		['te'] = 'ISO 15919 Indic',
		['beng'] = 'ISO 15919 Indic',
		['brah'] = 'ISO 15919 Indic',
		['deva'] = 'ISO 15919 Indic',
		['gujr'] = 'ISO 15919 Indic',
		['guru'] = 'ISO 15919 Indic',
		['knda'] = 'ISO 15919 Indic',
		['mlym'] = 'ISO 15919 Indic',
		['orya'] = 'ISO 15919 Indic',
		['sinh'] = 'ISO 15919 Indic',
		['taml'] = 'ISO 15919 Indic',
		['telu'] = 'ISO 15919 Indic',

		['default'] = 'ISO transliteration',
		},

	['jyutping'] = {
		['default'] = 'Jyutping transliteration',
		},

	['mlcts'] = {
		['default'] = 'Myanmar Language Commission Transcription System',
		},

	['mr'] = {
		['default'] = 'McCune–Reischauer transliteration',
		},

	['nihon-shiki'] = {
		['default'] = 'Nihon-shiki transliteration',
		},

	['no_std'] = {																-- when no transliteration standard is supplied
		['akk'] = 'Semitic transliteration',
		['sem'] = 'Semitic transliteration',
		['phnx'] = 'Semitic transliteration',
		['xsux'] = 'Cuneiform transliteration',
		},

	['pinyin'] = {
		['default'] = 'Pinyin transliteration',
		},

	['rr'] = {
		['default'] = 'Revised Romanization of Korean transliteration',
		},

	['rtgs'] = {
		['default'] = 'Royal Thai General System of Transcription',
		},
	
	['satts'] = {
		['default'] = 'Standard Arabic Technical Transliteration System transliteration',
		},

	['scientific'] = {
		['default'] = 'scientific transliteration',
		},

	['ukrainian'] = {
		['default'] = 'Ukrainian National system of romanization',
		},

	['ungegn'] = {
		['default'] = 'United Nations Group of Experts on Geographical Names transliteration',
		},

	['wadegile'] = {
		['default'] = 'Wade–Giles transliteration',
		},

	['wehr'] = {
		['default'] = 'Hans Wehr transliteration',
		},
	};

return {
  translit_title_table = translit_title_table
}
