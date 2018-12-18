
&НаКлиенте
Функция ПолучитьСтруктуруПараметров()
	
	СтруктураПараметров = Новый Структура("ReleaseXid,Description,InCustomsClearedDate,StatusCodeXid,StatusGroupXid", 
											СокрЛП(ReleaseXid), 
											?(InCustomsCleared = 1, "IN CUSTOMS", "CLEAR"),
											InCustomsClearedDate);
											
	//1 - In customs, 2 - Cleared
	Если ImpExp = ПредопределенноеЗначение("Перечисление.ИмпортЭкспорт.Import") Тогда 
		СтруктураПараметров.StatusGroupXid = "IMPORT CUSTOMS";
		СтруктураПараметров.StatusCodeXid = ?(InCustomsCleared = 1, "IC4", "IC5");
	иначе
		СтруктураПараметров.StatusGroupXid = "EXPORT CUSTOMS";
		СтруктураПараметров.StatusCodeXid = ?(InCustomsCleared = 1, "EC4", "EC5");
	КонецЕсли;	
		
	Возврат СтруктураПараметров;
	
КонецФункции


////////////////////////////////////////////////////////////////////////////////////////////////
// VALIDATE

&НаКлиенте
Процедура Validate(Команда)
	
	Если Не ПроверитьЗаполнение() Тогда
		Возврат;
	КонецЕсли;
	
	ClearanceEventValidateНаСервере(ПолучитьСтруктуруПараметров());
	
КонецПроцедуры

&НаСервереБезКонтекста
Процедура ClearanceEventValidateНаСервере(СтруктураПараметров)
	
	TransmissionBody = Обработки.PushClearanceEventsToTMS.ПолучитьTransmissionBody(СтруктураПараметров);
	Если TransmissionBody = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	TransmissionBody.Проверить();
	
КонецПроцедуры


////////////////////////////////////////////////////////////////////////////////////////////////
// SAVE AS XML

&НаКлиенте
Процедура SaveAsXML(Команда)
	
	Если Не ПроверитьЗаполнение() Тогда
		Возврат;
	КонецЕсли;

	ДиалогВыбораФайла = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Сохранение);	
	ДиалогВыбораФайла.Фильтр = "XML files|*.xml";	
	Если НЕ ДиалогВыбораФайла.Выбрать() Тогда
		Возврат;
	КонецЕсли;
	
	PathToXML = ДиалогВыбораФайла.ПолноеИмяФайла;
	
	ClearanceEventSaveAsXMLНаСервере(ПолучитьСтруктуруПараметров(), PathToXML);
	
КонецПроцедуры

&НаСервереБезКонтекста
Процедура ClearanceEventSaveAsXMLНаСервере(СтруктураПараметров, PathToXML)
	
	TransmissionBody = Обработки.PushClearanceEventsToTMS.ПолучитьTransmissionBody(СтруктураПараметров);
	Если TransmissionBody = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ФабрикаXDTOTMS = Обработки.PushClearanceEventsToTMS.ПолучитьФабрикуXDTOTMS();
	
	ЗаписьXML = Новый ЗаписьXML;
	ЗаписьXML.ОткрытьФайл(PathToXML);
	
	ФабрикаXDTOTMS.ЗаписатьXML(ЗаписьXML, TransmissionBody, , TMSСервер.ПолучитьURIПространстваИменTMS());
	
	ЗаписьXML.Закрыть();
	
	Сообщить("Ok");
	
КонецПроцедуры


////////////////////////////////////////////////////////////////////////////////////////////////
// Clearance Event UNLOAD TO TMS

&НаКлиенте
Процедура UnloadToTMS(Команда)
	
	Если Не ПроверитьЗаполнение() Тогда
		Возврат;
	КонецЕсли;

	ClearanceEventUnloadToTMSНаСервере(ПолучитьСтруктуруПараметров());	
	
КонецПроцедуры

&НаСервереБезКонтекста
Процедура ClearanceEventUnloadToTMSНаСервере(СтруктураПараметров)
	
	TransmissionBody = Обработки.PushClearanceEventsToTMS.ПолучитьTransmissionBody(СтруктураПараметров);
	Если TransmissionBody = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	TransmissionAck = Обработки.PushClearanceEventsToTMS.CallTMS(TransmissionBody);
	
	Сообщить("Reply:");
	СвойстваTransmissionAck = TransmissionAck.Свойства();
	Для Каждого Свойство Из СвойстваTransmissionAck Цикл
		Сообщить(Свойство.Имя + ":
			|" + TransmissionAck.Получить(Свойство));		
	КонецЦикла;
	
КонецПроцедуры


