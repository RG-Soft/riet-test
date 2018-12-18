
&НаКлиенте
Процедура AUНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	Если НЕ ЗначениеЗаполнено(Объект.Segment) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Choose Segment first!",
			, "Segment", "Объект");
		СтандартнаяОбработка = Ложь;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура DefaultWHПриИзменении(Элемент)
	
	Если ЗначениеЗаполнено(Объект.DefaultWH) Тогда 
		Предупреждение("'Warehouse To' will be updated in all parcels that have current BORG and Warehouse From is RUS_SPBM or RUS_MJRM, except included in Trips!"
		, , "Notification");
	КонецЕсли;
	
КонецПроцедуры
