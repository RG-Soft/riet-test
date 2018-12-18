
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	DomesticInternational = Перечисления.DomesticInternational.International;
	
КонецПроцедуры


////////////////////////////////////////////////////////////////////////////////////////////////
// EXPORT REQUEST VALIDATE

&НаКлиенте
Процедура Validate(Команда)
	
	Если НЕ ЗначениеЗаполнено(ExportRequest) Тогда
		          				
		Сообщить("'Export request' is empty!");
		Возврат;
			     				
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(DomesticInternational) Тогда
		          				
		Сообщить("'Domestic / international' is empty!");
		Возврат;
			     				
	КонецЕсли;
	
	ValidateНаСервере(ExportRequest, DomesticInternational);
			
КонецПроцедуры

&НаСервереБезКонтекста
Процедура ValidateНаСервере(ExportRequest, DomesticInternational)
	
	Структура = ПолучитьPayloadИФабрикуXDTO(ExportRequest, DomesticInternational);
	Структура.Payload.Проверить();
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьPayloadИФабрикуXDTO(ExportRequest, DomesticInternational)
	
	WSСсылка = Обработки.PushExportToTMS.ПолучитьWSСсылку();
	ФабрикаXDTOTMS = WSСсылка.ПолучитьWSОпределения().ФабрикаXDTO;
	TransOrder = Обработки.PushExportToTMS.ПолучитьTransOrder(ФабрикаXDTOTMS, ExportRequest, DomesticInternational);	
	Payload = Обработки.PushExportToTMS.ПолучитьPayload(ФабрикаXDTOTMS, TransOrder);
	
	СтруктураВозврата = Новый Структура;
	СтруктураВозврата.Вставить("ФабрикаXDTO", ФабрикаXDTOTMS);
	СтруктураВозврата.Вставить("Payload", Payload);
	
	Возврат СтруктураВозврата;
	
КонецФункции


////////////////////////////////////////////////////////////////////////////////////////////////
// EXPORT REQUEST SAVE AS XML

&НаКлиенте
Процедура SaveAsXML(Команда)
	
	Если НЕ ЗначениеЗаполнено(ExportRequest) Тогда
		          				
		Сообщить("Export request is empty!");
		Возврат;
			     				
	КонецЕсли;

	Если НЕ ЗначениеЗаполнено(DomesticInternational) Тогда
		          				
		Сообщить("'Domestic / international' is empty!");
		Возврат;
			     				
	КонецЕсли;
	
	ДиалогВыбораФайла = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Сохранение);	
	ДиалогВыбораФайла.Фильтр = "XML files|*.xml";	
	Если НЕ ДиалогВыбораФайла.Выбрать() Тогда
		Возврат;
	КонецЕсли;	
	PathToXML = ДиалогВыбораФайла.ПолноеИмяФайла;
	
	АдресФайла = SaveAsXMLНаСервере(ExportRequest, DomesticInternational);
	ДвоичныеДанные = ПолучитьИзВременногоХранилища(АдресФайла);
	ДвоичныеДанные.Записать(PathToXML);
		
КонецПроцедуры

&НаСервереБезКонтекста
Функция SaveAsXMLНаСервере(ExportRequest, DomesticInternational)
	
	Структура = ПолучитьPayloadИФабрикуXDTO(ExportRequest, DomesticInternational);
	Структура.Payload.Проверить();
	
	ИмяВременногоФайла = ПолучитьИмяВременногоФайла("xml");
	
	ЗаписьXML = Новый ЗаписьXML;
	ЗаписьXML.ОткрытьФайл(ИмяВременногоФайла);
	Структура.ФабрикаXDTO.ЗаписатьXML(ЗаписьXML, Структура.Payload);
	ЗаписьXML.Закрыть();
	
	ДвоичныеДанные = Новый ДвоичныеДанные(ИмяВременногоФайла);
	
	УдалитьФайлы(ИмяВременногоФайла);
	
	Возврат ПоместитьВоВременноеХранилище(ДвоичныеДанные);
		
КонецФункции


////////////////////////////////////////////////////////////////////////////////////////////////
// EXPORT REQUEST UNLOAD TO TMS

&НаКлиенте
Процедура PushToTMS(Команда)
	
	Если НЕ ЗначениеЗаполнено(ExportRequest) Тогда
		          				
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Select Export request!",
			, "Объект", "ExportRequest");
			Возврат;
			     				
	КонецЕсли;

	PushToTMSНаСервере(ExportRequest, DomesticInternational);
	
КонецПроцедуры

&НаСервереБезКонтекста
Процедура PushToTMSНаСервере(ExportRequest, DomesticInternational)
	
	Обработки.PushExportToTMS.PushExportToTMS(ExportRequest, DomesticInternational);
	
КонецПроцедуры

