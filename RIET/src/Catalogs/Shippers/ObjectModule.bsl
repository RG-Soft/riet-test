
Процедура ПередЗаписью(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	ДозаполнитьРеквизитыБезДополнительныхДанных();
		
	ПроверитьРеквизитыБезДополнительныхДанных(Отказ);
	
КонецПроцедуры

Процедура ДозаполнитьРеквизитыБезДополнительныхДанных()
	
	Наименование = СокрЛП(Наименование);
	Address1 = СокрЛП(Address1);
	Address2 = СокрЛП(Address2);
	Address3 = СокрЛП(Address3);
	CityLocation = СокрЛП(CityLocation);
	Country = СокрЛП(Country);
	
КонецПроцедуры

Процедура ПроверитьРеквизитыБезДополнительныхДанных(Отказ)
	
	Если ПометкаУдаления Тогда
		Возврат;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(СокрЛП(Код)) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"""Code"" is empty!",
			ЭтотОбъект, "Код", , Отказ);
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Наименование) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"""Name"" is empty!",
			ЭтотОбъект, "Наименование", , Отказ);
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(CityLocation) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"""City / location"" is empty!",
			ЭтотОбъект, "CityLocation", , Отказ);
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Country) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"""Country"" is empty!",
			ЭтотОбъект, "Country", , Отказ);
	КонецЕсли;
	
КонецПроцедуры