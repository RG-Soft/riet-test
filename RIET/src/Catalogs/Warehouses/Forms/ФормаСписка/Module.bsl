
&НаКлиенте
Процедура UpdateAllFromTMS(Команда)
	
	UpdateAllFromTMSНаСервере();
	
	Предупреждение("Done", 60, "Update all locations from TMS");
	
КонецПроцедуры

&НаСервереБезКонтекста
Процедура UpdateAllFromTMSНаСервере()
	
	Справочники.Warehouses.ОбновитьTMSLocations();
	
КонецПроцедуры
