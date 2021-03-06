
///////////////////////////////////////////////////////////////////////////////////////
// ПЕРЕД ЗАПИСЬЮ

Процедура ПередЗаписью(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	ДозаполнитьРеквизитыБезДополнительныхДанных();
	
	ПроверитьЗаполнениеРеквзитов(Отказ);
	
КонецПроцедуры


///////////////////////////////////////////////////////////////////////////////////////

Процедура ДозаполнитьРеквизитыБезДополнительныхДанных()
	
	Код = СокрЛП(Код);
	Наименование = СокрЛП(Наименование);
	NameForMoveIT = СокрЛП(NameForMoveIT);
	TMSID = СокрЛП(TMSID);
	
КонецПроцедуры


///////////////////////////////////////////////////////////////////////////////////////

Процедура ПроверитьЗаполнениеРеквзитов(Отказ)
	
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
	
	Если НЕ ЗначениеЗаполнено(TMSID) Тогда
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"""TMS ID"" is empty!",
			ЭтотОбъект, "TMSID", , Отказ);
			
	Иначе
		
		// Проверим уникальность TMS ID
		Запрос = Новый Запрос;
		Запрос.УстановитьПараметр("TMSID", TMSID);
		Запрос.УстановитьПараметр("Ссылка", Ссылка);
		Запрос.Текст = 
			"ВЫБРАТЬ
			|	CountriesOfProcessLevels.Представление
			|ИЗ
			|	Справочник.CountriesOfProcessLevels КАК CountriesOfProcessLevels
			|ГДЕ
			|	CountriesOfProcessLevels.TMSID = &TMSID
			|	И НЕ CountriesOfProcessLevels.ПометкаУдаления
			|	И CountriesOfProcessLevels.Ссылка <> &Ссылка";
			
		Выборка = Запрос.Выполнить().Выбрать();
		Пока Выборка.Следующий() Цикл
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"TMS ID """ + TMSID + """ is already used in Country """ + Выборка.Представление + """!",
				ЭтотОбъект, "TMSID", , Отказ);
		КонецЦикла;
		
	КонецЕсли;
	
КонецПроцедуры
