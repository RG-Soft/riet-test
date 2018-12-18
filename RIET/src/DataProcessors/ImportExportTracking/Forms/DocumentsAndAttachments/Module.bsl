
///////////////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ ФОРМЫ

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ЗаполнитьТаблицу();
		
КонецПроцедуры

Процедура ЗаполнитьТаблицу()
	
	СтруктураПараметров = Новый Структура;
	СтруктураТекстов = Новый Структура;
	
	Отбор = Параметры.Отбор;
	
	Если Отбор.Свойство("Invoice") И ЗначениеЗаполнено(Отбор.Invoice) Тогда
		
		СтруктураПараметров.Вставить("Invoice", Отбор.Invoice);
		СтруктураТекстов.Вставить("Invoice", 
			"ВЫБРАТЬ
		 	|	""Import invoice"" КАК DocumentType,
		 	|	Invoices.Номер КАК DocumentNo,
		 	|	Invoices.Дата КАК DocumentDate,
		 	|	ИнвойсПрисоединенныеФайлы.Ссылка КАК Attachment,
		 	|	ИнвойсПрисоединенныеФайлы.Ссылка.Представление КАК AttachmentName,
		 	|	ИнвойсПрисоединенныеФайлы.Расширение КАК AttachmentExtension,
		 	|	ИнвойсПрисоединенныеФайлы.ИндексКартинки
		 	|ИЗ
		 	|	Документ.Инвойс КАК Invoices
		 	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ИнвойсПрисоединенныеФайлы КАК ИнвойсПрисоединенныеФайлы
		 	|		ПО Invoices.Ссылка = ИнвойсПрисоединенныеФайлы.ВладелецФайла
		 	|			И ((НЕ ИнвойсПрисоединенныеФайлы.ПометкаУдаления))
		 	|ГДЕ
		 	|	Invoices.Ссылка = &Invoice");
		
	КонецЕсли;
		
	Если Отбор.Свойство("DOC") И ЗначениеЗаполнено(Отбор.DOC) Тогда
		
		СтруктураПараметров.Вставить("DOC", Отбор.DOC);
		СтруктураТекстов.Вставить("DOC", 
			"ВЫБРАТЬ
			|	""DOC"" КАК DocumentType,
			|	DOCs.Номер КАК DocumentNo,
			|	DOCs.Дата КАК DocumentDate,
			|	КонсолидированныйПакетЗаявокНаПеревозкуПрисоединенныеФайлы.Ссылка КАК Attachment,
			|	КонсолидированныйПакетЗаявокНаПеревозкуПрисоединенныеФайлы.Ссылка.Представление КАК AttachmentName,
			|	КонсолидированныйПакетЗаявокНаПеревозкуПрисоединенныеФайлы.Расширение КАК AttachmentExtension,
			|	КонсолидированныйПакетЗаявокНаПеревозкуПрисоединенныеФайлы.ИндексКартинки
			|ИЗ
			|	Документ.КонсолидированныйПакетЗаявокНаПеревозку КАК DOCs
			|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.КонсолидированныйПакетЗаявокНаПеревозкуПрисоединенныеФайлы КАК КонсолидированныйПакетЗаявокНаПеревозкуПрисоединенныеФайлы
			|		ПО DOCs.Ссылка = КонсолидированныйПакетЗаявокНаПеревозкуПрисоединенныеФайлы.ВладелецФайла
			|			И ((НЕ КонсолидированныйПакетЗаявокНаПеревозкуПрисоединенныеФайлы.ПометкаУдаления))
			|ГДЕ
			|	DOCs.Ссылка = &DOC");
		
	КонецЕсли;	
	
	Если Отбор.Свойство("Shipment") И ЗначениеЗаполнено(Отбор.Shipment) Тогда
		
		СтруктураПараметров.Вставить("ImportShipment", Отбор.Shipment);
		СтруктураТекстов.Вставить("ImportShipment", 
			"ВЫБРАТЬ
			|	""Import shipment"" КАК DocumentType,
			|	ImportShipments.Номер КАК DocumentNo,
			|	ImportShipments.Дата КАК DocumentDate,
			|	ПоставкаПрисоединенныеФайлы.Ссылка КАК Attachment,
			|	ПоставкаПрисоединенныеФайлы.Ссылка.Представление КАК AttachmentName,
			|	ПоставкаПрисоединенныеФайлы.Расширение КАК AttachmentExtension,
			|	ПоставкаПрисоединенныеФайлы.ИндексКартинки
			|ИЗ
			|	Документ.Поставка КАК ImportShipments
			|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ПоставкаПрисоединенныеФайлы КАК ПоставкаПрисоединенныеФайлы
			|		ПО ImportShipments.Ссылка = ПоставкаПрисоединенныеФайлы.ВладелецФайла
			|			И ((НЕ ПоставкаПрисоединенныеФайлы.ПометкаУдаления))
			|ГДЕ
			|	ImportShipments.Ссылка = &ImportShipment");
		
	КонецЕсли;	
	
	Если Отбор.Свойство("ExportRequest") И ЗначениеЗаполнено(Отбор.ExportRequest) Тогда
		
		СтруктураПараметров.Вставить("ExportRequest", Отбор.ExportRequest);
		СтруктураТекстов.Вставить("ExportRequest", 
			"ВЫБРАТЬ
			|	""Export request"" КАК DocumentType,
			|	ExportRequests.Номер КАК DocumentNo,
			|	ExportRequests.Дата КАК DocumentDate,
			|	ExportRequestПрисоединенныеФайлы.Ссылка КАК Attachment,
			|	ExportRequestПрисоединенныеФайлы.Ссылка.Представление КАК AttachmentName,
			|	ExportRequestПрисоединенныеФайлы.Расширение КАК AttachmentExtension,
			|	ExportRequestПрисоединенныеФайлы.ИндексКартинки
			|ИЗ
			|	Документ.ExportRequest КАК ExportRequests
			|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ExportRequestПрисоединенныеФайлы КАК ExportRequestПрисоединенныеФайлы
			|		ПО ExportRequests.Ссылка = ExportRequestПрисоединенныеФайлы.ВладелецФайла
			|			И ((НЕ ExportRequestПрисоединенныеФайлы.ПометкаУдаления))
			|ГДЕ
			|	ExportRequests.Ссылка = &ExportRequest");
		
	КонецЕсли;
	
	Если Отбор.Свойство("ExportShipment") И ЗначениеЗаполнено(Отбор.ExportShipment) Тогда
		
		СтруктураПараметров.Вставить("ExportShipment", Отбор.ExportShipment);
		СтруктураТекстов.Вставить("ExportShipment", 
			"ВЫБРАТЬ
			|	""Export shipment"" КАК DocumentType,
			|	ExportShipments.Номер КАК DocumentNo,
			|	ExportShipments.Дата КАК DocumentDate,
			|	ExportShipmentПрисоединенныеФайлы.Ссылка КАК Attachment,
			|	ExportShipmentПрисоединенныеФайлы.Ссылка.Представление КАК AttachmentName,
			|	ExportShipmentПрисоединенныеФайлы.Расширение КАК AttachmentExtension,
			|	ExportShipmentПрисоединенныеФайлы.ИндексКартинки
			|ИЗ
			|	Документ.ExportShipment КАК ExportShipments
			|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ExportShipmentПрисоединенныеФайлы КАК ExportShipmentПрисоединенныеФайлы
			|		ПО ExportShipments.Ссылка = ExportShipmentПрисоединенныеФайлы.ВладелецФайла
			|			И ((НЕ ExportShipmentПрисоединенныеФайлы.ПометкаУдаления))
			|ГДЕ
			|	ExportShipments.Ссылка = &ExportShipment");
		
	КонецЕсли;
	
	Если Отбор.Свойство("CustomsFile") И ЗначениеЗаполнено(Отбор.CustomsFile) Тогда
		
		СтруктураПараметров.Вставить("CustomsFile", Отбор.CustomsFile);
		СтруктураТекстов.Вставить("CustomsFile", 
			"ВЫБРАТЬ
		 	|	""Customs file"" КАК DocumentType,
		 	|	CCDs.Номер КАК DocumentNo,
		 	|	CCDs.Дата КАК DocumentDate,
		 	|	ГТДПрисоединенныеФайлы.Ссылка КАК Attachment,
		 	|	ГТДПрисоединенныеФайлы.Ссылка.Представление КАК AttachmentName,
		 	|	ГТДПрисоединенныеФайлы.Расширение КАК AttachmentExtension,
		 	|	ГТДПрисоединенныеФайлы.ИндексКартинки
		 	|ИЗ
		 	|	Документ.ГТД КАК CCDs
		 	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ГТДПрисоединенныеФайлы КАК ГТДПрисоединенныеФайлы
		 	|		ПО CCDs.Ссылка = ГТДПрисоединенныеФайлы.ВладелецФайла
		 	|			И ((НЕ ГТДПрисоединенныеФайлы.ПометкаУдаления))
		 	|ГДЕ
		 	|	CCDs.Ссылка = &CustomsFile");
		
	КонецЕсли;
		
	Если Отбор.Свойство("TransportRequest") И ЗначениеЗаполнено(Отбор.TransportRequest) Тогда
		
		СтруктураПараметров.Вставить("TransportRequest", Отбор.TransportRequest);
		СтруктураТекстов.Вставить("TransportRequest", 
			"ВЫБРАТЬ
			|	""Transport request"" КАК DocumentType,
			|	TransportRequest.Номер КАК DocumentNo,
			|	TransportRequest.Дата КАК DocumentDate,
			|	TransportRequestПрисоединенныеФайлы.Ссылка КАК Attachment,
			|	TransportRequestПрисоединенныеФайлы.Ссылка.Представление КАК AttachmentName,
			|	TransportRequestПрисоединенныеФайлы.Расширение КАК AttachmentExtension,
			|	TransportRequestПрисоединенныеФайлы.ИндексКартинки
			|ИЗ
			|	Документ.TransportRequest КАК TransportRequest
			|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.TransportRequestПрисоединенныеФайлы КАК TransportRequestПрисоединенныеФайлы
			|		ПО TransportRequest.Ссылка = TransportRequestПрисоединенныеФайлы.ВладелецФайла
			|			И (НЕ TransportRequestПрисоединенныеФайлы.ПометкаУдаления)
			|ГДЕ
			|	TransportRequest.Ссылка = &TransportRequest");
		
	КонецЕсли;
	     
	УстановитьПривилегированныйРежим(Истина);
	СтруктураРезультатов = РГСофт.ПолучитьСтруктуруРезультатовТекстовЗапросов(СтруктураТекстов, СтруктураПараметров);
	УстановитьПривилегированныйРежим(Ложь);
	
	Если СтруктураРезультатов.Свойство("Invoice") Тогда
		
		ВыборкаInvoice = СтруктураРезультатов.Invoice.Выбрать();
		ДобавитьВТаблицуСтрокиИзВыборки(ВыборкаInvoice);
		
	КонецЕсли;
	
	Если СтруктураРезультатов.Свойство("DOC") Тогда
		
		ВыборкаDOC = СтруктураРезультатов.DOC.Выбрать();
		ДобавитьВТаблицуСтрокиИзВыборки(ВыборкаDOC);
		
	КонецЕсли;
	
	Если СтруктураРезультатов.Свойство("ImportShipment") Тогда
		
		ВыборкаImportShipment = СтруктураРезультатов.ImportShipment.Выбрать();
		ДобавитьВТаблицуСтрокиИзВыборки(ВыборкаImportShipment);
		
	КонецЕсли;
	
	Если СтруктураРезультатов.Свойство("ExportRequest") Тогда
		
		ВыборкаExportRequest = СтруктураРезультатов.ExportRequest.Выбрать();
		ДобавитьВТаблицуСтрокиИзВыборки(ВыборкаExportRequest);
		
	КонецЕсли;
	
	Если СтруктураРезультатов.Свойство("ExportShipment") Тогда
		
		ВыборкаExportShipment = СтруктураРезультатов.ExportShipment.Выбрать();
		ДобавитьВТаблицуСтрокиИзВыборки(ВыборкаExportShipment);
		
	КонецЕсли;
	
	Если СтруктураРезультатов.Свойство("CustomsFile") Тогда
		
		ВыборкаCustomsFile = СтруктураРезультатов.CustomsFile.Выбрать();
		ДобавитьВТаблицуСтрокиИзВыборки(ВыборкаCustomsFile);
		
	КонецЕсли;
	
	Если СтруктураРезультатов.Свойство("TransportRequest") Тогда
		
		ВыборкаTransportRequest = СтруктураРезультатов.TransportRequest.Выбрать();
		ДобавитьВТаблицуСтрокиИзВыборки(ВыборкаTransportRequest);
		
	КонецЕсли;

КонецПроцедуры

Процедура ДобавитьВТаблицуСтрокиИзВыборки(Выборка)
	
	Пока Выборка.Следующий() Цикл
		
		НоваяСтрока = DocumentsAndAttachments.Добавить();
		НоваяСтрока.DocumentType = Выборка.DocumentType;
		НоваяСтрока.DocumentNo = Выборка.DocumentNo;
		НоваяСтрока.DocumentDate = Выборка.DocumentDate;
		Если ЗначениеЗаполнено(Выборка.Attachment) Тогда
			НоваяСтрока.Attachment = Выборка.Attachment;
			НоваяСтрока.AttachmentName = СокрЛП(Выборка.AttachmentName) + "." + СокрЛП(Выборка.AttachmentExtension);
			НоваяСтрока.ИндексКартинки = Выборка.ИндексКартинки;
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры


///////////////////////////////////////////////////////////////////////////////////////////
// ТАБЛИЦА

&НаКлиенте
Процедура DocumentsAndAttachmentsВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	OpenSaveAttachmentНаКлиенте();
	
КонецПроцедуры

&НаКлиенте
Процедура OpenSaveAttachment(Команда)
	
    OpenSaveAttachmentНаКлиенте();	

КонецПроцедуры

&НаКлиенте
Процедура OpenSaveAttachmentНаКлиенте()
	
	ТекДанные = Элементы.DocumentsAndAttachments.ТекущиеДанные;
	Если ТекДанные <> Неопределено Тогда
		
		Если ЗначениеЗаполнено(ТекДанные.Attachment) Тогда 
					
			ДанныеФайла = ПрисоединенныеФайлыСлужебныйВызовСервера.ПолучитьДанныеФайла(ТекДанные.Attachment, УникальныйИдентификатор);
			ПолучитьФайл(ДанныеФайла.СсылкаНаДвоичныеДанныеФайла, ДанныеФайла.ИмяФайла, Истина);
		
		Иначе
			
			ПоказатьПредупреждение(, "No attachments found for " + ТекДанные.DocumentType + " #" + ТекДанные.DocumentNo, 30);
			
		КонецЕсли;
		
	КонецЕсли;

КонецПроцедуры