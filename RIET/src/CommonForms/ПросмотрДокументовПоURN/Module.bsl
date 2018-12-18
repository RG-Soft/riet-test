

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Заголовок = "URN: " + URN;
	HTMLДок = "https://documentflowmanagerslbap.accenture.com/SCHLUMBERGERWORLDSSO/Pages/ShowPDF.aspx?page=RetrDocView.aspx&URN=" + URN + "&IsParched=False";
	
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)

	URN = СтрЗаменить(Параметры.URN, Символы.НПП, "");
	
КонецПроцедуры
