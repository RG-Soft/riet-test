
////////////////////////////////////////////////////////////////////////////////////////////////
// REQUEST VALIDATE

&НаКлиенте
Процедура Validate(Команда)
	
	Если НЕ ЗначениеЗаполнено(TransportRequest) Тогда
		          				
		Сообщить("'Transport request' is empty!");
		Возврат;
			     				
	КонецЕсли;
	       		
	ValidateНаСервере(TransportRequest);
			
КонецПроцедуры

&НаСервереБезКонтекста
Процедура ValidateНаСервере(TransportRequest)
	
	Структура = ПолучитьPayloadИФабрикуXDTO(TransportRequest);
	Структура.Payload.Проверить();
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьPayloadИФабрикуXDTO(TransportRequest)
	
	WSСсылка = Обработки.PushTransportRequestToTMS.ПолучитьWSСсылку();
	ФабрикаXDTOTMS = WSСсылка.ПолучитьWSОпределения().ФабрикаXDTO;
	TransOrder = Обработки.PushTransportRequestToTMS.ПолучитьTransOrder(ФабрикаXDTOTMS, TransportRequest);	
	Payload = Обработки.PushTransportRequestToTMS.ПолучитьPayload(ФабрикаXDTOTMS, TransOrder);
	
	СтруктураВозврата = Новый Структура;
	СтруктураВозврата.Вставить("ФабрикаXDTO", ФабрикаXDTOTMS);
	СтруктураВозврата.Вставить("Payload", Payload);
	
	Возврат СтруктураВозврата;
	
КонецФункции


////////////////////////////////////////////////////////////////////////////////////////////////
// EXPORT REQUEST SAVE AS XML

&НаКлиенте
Процедура SaveAsXML(Команда)
	
	Если НЕ ЗначениеЗаполнено(TransportRequest) Тогда
		          				
		Сообщить("Transport request is empty!");
		Возврат;
			     				
	КонецЕсли;
	
	ДиалогВыбораФайла = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Сохранение);	
	ДиалогВыбораФайла.Фильтр = "XML files|*.xml";	
	Если НЕ ДиалогВыбораФайла.Выбрать() Тогда
		Возврат;
	КонецЕсли;	
	PathToXML = ДиалогВыбораФайла.ПолноеИмяФайла;
	
	АдресФайла = SaveAsXMLНаСервере(TransportRequest);
	ДвоичныеДанные = ПолучитьИзВременногоХранилища(АдресФайла);
	ДвоичныеДанные.Записать(PathToXML);
		
КонецПроцедуры

&НаСервереБезКонтекста
Функция SaveAsXMLНаСервере(TransportRequest)
	
	Структура = ПолучитьPayloadИФабрикуXDTO(TransportRequest);
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
// TRANSPORT REQUEST UNLOAD TO TMS

&НаКлиенте
Процедура PushToTMS(Команда)
	
	Если НЕ ЗначениеЗаполнено(TransportRequest) Тогда
		          				
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Select Transport request!",
			, "Объект", "TransportRequest");
			Возврат;
			     				
	КонецЕсли;

	PushToTMSНаСервере(TransportRequest);
	
КонецПроцедуры

&НаСервереБезКонтекста
Процедура PushToTMSНаСервере(TransportRequest)
	
	Обработки.PushTransportRequestToTMS.PushTransportRequestToTMS(TransportRequest);
	
КонецПроцедуры

