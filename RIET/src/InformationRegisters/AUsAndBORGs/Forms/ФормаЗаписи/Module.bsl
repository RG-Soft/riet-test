
&НаКлиенте
Процедура AUНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	СтруктураНастройки = Новый Структура;
	СтруктураНастройки.Вставить("Имя", "ВыборИзAUsAndBORGs");
	СтруктураНастройки.Вставить("BORG", Запись.BORG);
	
	СтруктураПараметров = Новый Структура;
	СтруктураПараметров.Вставить("СтруктураНастройки", СтруктураНастройки);
	ОткрытьФорму("Справочник.КостЦентры.ФормаВыбора", СтруктураПараметров, Элемент);
	
КонецПроцедуры

&НаКлиенте
Процедура BORGНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	СтруктураНастройки = Новый Структура;
	СтруктураНастройки.Вставить("Имя", "ВыборИзAUsAndBORGs");
	СтруктураНастройки.Вставить("AU", Запись.AU);
	
	СтруктураПараметров = Новый Структура;
	СтруктураПараметров.Вставить("СтруктураНастройки", СтруктураНастройки);
	ОткрытьФорму("Справочник.BORGs.ФормаВыбора", СтруктураПараметров, Элемент);
	
КонецПроцедуры
