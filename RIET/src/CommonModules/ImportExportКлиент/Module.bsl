
Процедура ПерезаполнитьCustomsFilesВShipmentПриНеобходимости(ТаблицаCustomsFiles, ShipmentСсылка, НужноПерезаполнитьCustomsFiles) Экспорт
	
	Если НЕ НужноПерезаполнитьCustomsFiles Тогда
		Возврат;
	КонецЕсли;
	
	ТаблицаCustomsFiles.Очистить();
	
	Если НЕ ЗначениеЗаполнено(ShipmentСсылка) Тогда
		Возврат;
	КонецЕсли;
	
	МассивСтруктур = ImportExportВызовСервера.ПолучитьДанныеCustomsFilesДляShipment(ShipmentСсылка);
	СтрокаРеквизитовCustomsFile = ImportExportКлиентСервер.ПолучитьСтрокуРеквизитовCustomsFileДляShipment();
	Для Каждого СтруктураCustomsFile Из МассивСтруктур Цикл
		НоваяСтрокаТаблицы = ТаблицаCustomsFiles.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрокаТаблицы, СтруктураCustomsFile, СтрокаРеквизитовCustomsFile);
	КонецЦикла;
	
	НужноПерезаполнитьCustomsFiles = Ложь;
	
КонецПроцедуры

Процедура ОбработкаКомандыCopyWithContentЗавершение(Результат, Параметры) Экспорт 
	
	Если Результат = КодВозвратаДиалога.Нет Тогда
		Возврат;
	КонецЕсли;
	
	НовыйExportRequest = ImportExportВызовСервера.CopyНаСервере(Параметры.ПараметрКоманды);
	Если ЗначениеЗаполнено(НовыйExportRequest) Тогда
		ПоказатьЗначение(, НовыйExportRequest);
	КонецЕсли;
	
КонецПроцедуры
