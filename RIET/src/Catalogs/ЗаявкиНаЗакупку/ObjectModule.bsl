
Процедура ПриКопировании(ОбъектКопирования)
	
	CustomsСервер.ОчиститьCreationModification(ЭтотОбъект);
	
КонецПроцедуры

Процедура ПередЗаписью(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	ДозаполнитьРеквизитыБезДополнительныхДанных();
	
	ПроверитьЗаполнениеРеквизитов(Отказ);
		
КонецПроцедуры

Процедура ДозаполнитьРеквизитыБезДополнительныхДанных()

	Код = СокрЛП(Код);
	Посредник = СокрЛП(Посредник);
	Поставщик = СокрЛП(Поставщик);
	СтранаПоставщика = СокрЛП(СтранаПоставщика);
	ТипПоставщика = СокрЛП(ТипПоставщика);
	ИмяЗаказчика = СокрЛП(ИмяЗаказчика);
	Податель = СокрЛП(Податель);
	Грузополучатель = СокрЛП(Грузополучатель);
	Комментарий = СокрЛП(Комментарий);
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Поставщик", Поставщик);
	Запрос.УстановитьПараметр("ДатаЗаявкиНаЗакупку", ДатаЗаявкиНаЗакупку);
	Запрос.Текст = "ВЫБРАТЬ
	               |	POSuppliersNotRequiringEUC.POSupplierName КАК SupplierNotRequiringEUC
	               |ИЗ
	               |	РегистрСведений.POSuppliersNotRequiringEUC КАК POSuppliersNotRequiringEUC
	               |ГДЕ
	               |	POSuppliersNotRequiringEUC.POSupplierName = &Поставщик
	               |	И POSuppliersNotRequiringEUC.PODateFrom <= &ДатаЗаявкиНаЗакупку";
	
	ВыборкаPOSuppliersNotRequiringEUC = Запрос.Выполнить().Выбрать();
	Если ВыборкаPOSuppliersNotRequiringEUC.Следующий() Тогда 
		EUCNotRequired = Истина; 
	КонецЕсли;
	
	Если EUCNotRequired Тогда 
		EUCRequested = Неопределено;
		EUCReceived = Неопределено;
	КонецЕсли;
	
	CustomsСервер.ЗаполнитьCreationModification(ЭтотОбъект);
	
КонецПроцедуры

Процедура ПроверитьЗаполнениеРеквизитов(Отказ)
	
	Если ПометкаУдаления Тогда
		Возврат;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(СокрЛП(Код)) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"No. is empty!",
			ЭтотОбъект, "Код", , Отказ);
	КонецЕсли;
	
	//Для Smith PO BORGа нет
	//Если НЕ ЗначениеЗаполнено(БОРГ) Тогда
	//	ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
	//		"BORG is empty!",
	//		ЭтотОбъект, "BORG", , Отказ);
	//КонецЕсли;
	
	Если ЗначениеЗаполнено(EUCReceived) И EUCRequested > EUCReceived Тогда 
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Requested date can not be later than Received date!",
			ЭтотОбъект, "EUCRequested", , Отказ);
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("PO", Ссылка);

	Запрос.Текст = "ВЫБРАТЬ
	               |	СтрокиИнвойса.Представление КАК Item,
	               |	СтрокиИнвойса.EUCNotRequired,
	               |	СтрокиИнвойса.EUCRequested,
	               |	СтрокиИнвойса.EUCReceived
	               |ИЗ
	               |	Справочник.СтрокиИнвойса КАК СтрокиИнвойса
	               |ГДЕ
	               |	НЕ СтрокиИнвойса.ПометкаУдаления
	               |	И СтрокиИнвойса.СтрокаЗаявкиНаЗакупку.Владелец = &PO";
	
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		
		Если EUCNotRequired <> Выборка.EUCNotRequired тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Non-critical err.: 'EUC not required' differs from item " + Выборка.Item,
				ЭтотОбъект, "EUCNotRequired");
		КонецЕсли;
		
		Если EUCRequested <> Выборка.EUCRequested тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Non-critical err.: 'EUC requested' differs from item " + Выборка.Item + " " + Формат(Выборка.EUCRequested, "ДЛФ=Д"),
				ЭтотОбъект, "EUCRequested");
		КонецЕсли;

		Если EUCReceived <> Выборка.EUCReceived тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Non-critical err.: 'EUC received' differs from item " + Выборка.Item + " " + Формат(Выборка.EUCReceived, "ДЛФ=Д"),
				ЭтотОбъект, "EUCReceived");
		КонецЕсли;
	
	КонецЦикла;      	
	
КонецПроцедуры
