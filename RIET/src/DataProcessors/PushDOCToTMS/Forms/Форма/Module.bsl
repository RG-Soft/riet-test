
////////////////////////////////////////////////////////////////////////////////////////////////
// REQUEST VALIDATE

&НаКлиенте
Процедура Validate(Команда)
	
	Если НЕ ЗначениеЗаполнено(DOC) Тогда
		          				
		Сообщить("'DOC' is empty!");
		Возврат;
			     				
	КонецЕсли;
	       		
	ValidateНаСервере(DOC);
			
КонецПроцедуры

&НаСервереБезКонтекста
Процедура ValidateНаСервере(DOC)
	
	Структура = ПолучитьPayloadИФабрикуXDTO(DOC);
	Структура.Payload.Проверить();
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьPayloadИФабрикуXDTO(DOC)
	
	WSСсылка = Обработки.PushDOCToTMS.ПолучитьWSСсылку();
	ФабрикаXDTOTMS = WSСсылка.ПолучитьWSОпределения().ФабрикаXDTO;
	МассивTransOrder = Обработки.PushDOCToTMS.ПолучитьМассивTransOrder(ФабрикаXDTOTMS, DOC);	
	Payload = Обработки.PushDOCToTMS.ПолучитьPayload(ФабрикаXDTOTMS, МассивTransOrder);
	
	СтруктураВозврата = Новый Структура;
	СтруктураВозврата.Вставить("ФабрикаXDTO", ФабрикаXDTOTMS);
	СтруктураВозврата.Вставить("Payload", Payload);
	
	Возврат СтруктураВозврата;
	
КонецФункции


////////////////////////////////////////////////////////////////////////////////////////////////
// EXPORT REQUEST SAVE AS XML

&НаКлиенте
Процедура SaveAsXML(Команда)
	
	Если НЕ ЗначениеЗаполнено(DOC) Тогда
		          				
		Сообщить("DOC is empty!");
		Возврат;
			     				
	КонецЕсли;
	
	ДиалогВыбораФайла = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Сохранение);	
	ДиалогВыбораФайла.Фильтр = "XML files|*.xml";	
	Если НЕ ДиалогВыбораФайла.Выбрать() Тогда
		Возврат;
	КонецЕсли;	
	PathToXML = ДиалогВыбораФайла.ПолноеИмяФайла;
	
	АдресФайла = SaveAsXMLНаСервере(DOC);
	ДвоичныеДанные = ПолучитьИзВременногоХранилища(АдресФайла);
	ДвоичныеДанные.Записать(PathToXML);
		
КонецПроцедуры

&НаСервереБезКонтекста
Функция SaveAsXMLНаСервере(DOC)
	
	Структура = ПолучитьPayloadИФабрикуXDTO(DOC);
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
// DOC UNLOAD TO TMS

&НаКлиенте
Процедура PushToTMS(Команда)
	
	Если НЕ ЗначениеЗаполнено(DOC) Тогда
		          				
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Select DOC!",
			, "Объект", "DOC");
			Возврат;
			     				
	КонецЕсли;

	PushToTMSНаСервере(DOC);
	
КонецПроцедуры

&НаСервереБезКонтекста
Процедура PushToTMSНаСервере(DOC)
	
	Обработки.PushDOCToTMS.PushDOCToTMS(DOC);
	
КонецПроцедуры

