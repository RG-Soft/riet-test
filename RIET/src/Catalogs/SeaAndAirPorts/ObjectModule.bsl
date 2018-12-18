
///////////////////////////////////////////////////////////////////////////////////////
// ПЕРЕД ЗАПИСЬЮ

Процедура ПередЗаписью(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	ДозаполнитьРеквизиты();	
	
	ПроверитьРеквизиты(Отказ);		
		
КонецПроцедуры


///////////////////////////////////////////////////////////////////////////////////////

Процедура ДозаполнитьРеквизиты()
	
	Код = СокрЛП(Код);
	Наименование = СокрЛП(Наименование);
	
	Если НЕ ЭтоГруппа Тогда
		
		Location = СокрЛП(Location);
		TMSID = СокрЛП(TMSID);
		
	КонецЕсли;
	
КонецПроцедуры


///////////////////////////////////////////////////////////////////////////////////////

Процедура ПроверитьРеквизиты(Отказ)
	
	Если ПометкаУдаления Тогда
		Возврат;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(СокрЛП(Код)) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"""No."" is empty!",
			ЭтотОбъект, "Код", , Отказ);
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Наименование) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"""Name"" is empty!",
			ЭтотОбъект, "Наименование", , Отказ);
	КонецЕсли;
	
	Если ЭтоГруппа Тогда
		Возврат;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Location) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"""Location"" is empty!",
			ЭтотОбъект, "Location", , Отказ);
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(DefaultWarehouse) Тогда
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"""Default warehouse"" is empty!",
			ЭтотОбъект, "DefaultWarehouse", , Отказ);
			
	ИначеЕсли DefaultWarehouse = Справочники.Warehouses.Other Тогда
			
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"You can not use ""Other"" default warehouse!",
			ЭтотОбъект, "DefaultWarehouse", , Отказ);	
			
	КонецЕсли;
	
	// Проверим уникальность TMS ID
	Если ЗначениеЗаполнено(TMSID) Тогда
		
		Запрос = Новый Запрос;
		Запрос.УстановитьПараметр("TMSID", TMSID);
		Запрос.УстановитьПараметр("Ссылка", Ссылка);
		Запрос.Текст = 
			"ВЫБРАТЬ
			|	SeaAndAirPorts.Представление
			|ИЗ
			|	Справочник.SeaAndAirPorts КАК SeaAndAirPorts
			|ГДЕ
			|	SeaAndAirPorts.TMSID = &TMSID
			|	И НЕ SeaAndAirPorts.ПометкаУдаления
			|	И SeaAndAirPorts.Ссылка <> &Ссылка";
			
		Выборка = Запрос.Выполнить().Выбрать();
		Пока Выборка.Следующий() Цикл
			
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"TMS ID """ + TMSID + """ is already used in Sea or air port """ + СокрЛП(Выборка.Представление) + """!",
				ЭтотОбъект, "TMSID", , Отказ);
			
		КонецЦикла;
		
	Иначе
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"""TMS ID"" is empty!",
			ЭтотОбъект, "TMSID", , Отказ);
		
	КонецЕсли;
	
КонецПроцедуры