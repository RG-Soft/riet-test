            
////////////////////////////////////////////////////////////////////////////////////////////////
// VALIDATE

//&НаКлиенте
//Процедура Validate(Команда)
//	
//	Если Не ПроверитьЗаполнение() Тогда
//		Возврат;
//	КонецЕсли;
//	
//	ClearanceEventValidateНаСервере();
//	
//КонецПроцедуры

//&НаСервереБезКонтекста
//Процедура ClearanceEventValidateНаСервере()
//	
//	TransmissionBody = ПолучитьTransmissionBody();
//	Если TransmissionBody = Неопределено Тогда
//		Возврат;
//	КонецЕсли;
//	
//	TransmissionBody.Проверить();
//	
//КонецПроцедуры


//////////////////////////////////////////////////////////////////////////////////////////////////
//// SAVE AS XML

//&НаКлиенте
//Процедура SaveAsXML(Команда)
//	
//	Если Не ПроверитьЗаполнение() Тогда
//		Возврат;
//	КонецЕсли;

//	ДиалогВыбораФайла = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Сохранение);	
//	ДиалогВыбораФайла.Фильтр = "XML files|*.xml";	
//	Если НЕ ДиалогВыбораФайла.Выбрать() Тогда
//		Возврат;
//	КонецЕсли;
//	
//	PathToXML = ДиалогВыбораФайла.ПолноеИмяФайла;
//	
//	GateInGateOutSaveAsXMLНаСервере(PathToXML);
//	
//КонецПроцедуры

//&НаСервереБезКонтекста
//Процедура GateInGateOutSaveAsXMLНаСервере(PathToXML)
//	
//	TransmissionBody = ПолучитьTransmissionBody();
//	Если TransmissionBody = Неопределено Тогда
//		Возврат;
//	КонецЕсли;
//	
//	WSСсылка = Обработки.PushClearanceEventsToTMS.ПолучитьWSСсылку();
//	ФабрикаXDTOTMS = WSСсылка.ПолучитьWSОпределения().ФабрикаXDTO;
//	
//	ЗаписьXML = Новый ЗаписьXML;
//	ЗаписьXML.ОткрытьФайл(PathToXML);
//	
//	ФабрикаXDTOTMS.ЗаписатьXML(ЗаписьXML, TransmissionBody, , TMSСервер.ПолучитьURIПространстваИменTMS());
//	
//	ЗаписьXML.Закрыть();
//	
//	Сообщить("Ok");
//	
//КонецПроцедуры


//////////////////////////////////////////////////////////////////////////////////////////////////
//// Gate In / Gate Out UNLOAD TO TMS

//&НаКлиенте
//Процедура UnloadToTMS(Команда)
//	
//	Если Не ПроверитьЗаполнение() Тогда
//		Возврат;
//	КонецЕсли;
//										
//	ОтветТекстовымДокументом = GateInGateOutUnloadToTMSНаСервере(СокрЛП(ShipmentNo));
//	
//	ОтветТекстовымДокументом.Показать();
//	
//КонецПроцедуры
//	
//&НаСервереБезКонтекста
//Функция GateInGateOutUnloadToTMSНаСервере(ShipmentNo)
//	
//	Возврат Обработки.PushGateInGateOutToTMS.PushGateInGateOutToTMS(ShipmentNo);
//				
//	
//	//TransmissionBody = ПолучитьTransmissionBody();
//	//Если TransmissionBody = Неопределено Тогда
//	//	Возврат;
//	//КонецЕсли;
//	//
//	//TransmissionAck = Обработки.PushClearanceEventsToTMS.CallTMS(TransmissionBody);
//	//
//	//Сообщить("Reply:");
//	//СвойстваTransmissionAck = TransmissionAck.Свойства();
//	//Для Каждого Свойство Из СвойстваTransmissionAck Цикл
//	//	Сообщить(Свойство.Имя + ":
//	//		|" + TransmissionAck.Получить(Свойство));		
//	//КонецЦикла;
//	
//КонецФункции

//&НаСервереБезКонтекста
//Функция ПолучитьTransmissionBody() 
//	
//	//передавать как параметры
//	ShipmentNo = "SH121030-00007";
//	StatusCode = "X6";
//	EventDate  = Строка(ТекущаяДата());
//	
//	WSСсылка = Обработки.PushClearanceEventsToTMS.ПолучитьWSСсылку();
//	ФабрикаXDTOTMS = WSСсылка.ПолучитьWSОпределения().ФабрикаXDTO;
//	
//	TransmissionBody = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "TransmissionBody");
//	
//	GLogXMLElement = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "GLogXMLElement");
//	
//	ShipmentStatus = ПолучитьShipmentStatus(ФабрикаXDTOTMS, ShipmentNo, StatusCode, EventDate);
//	GLogXMLElement.ShipmentStatus = ShipmentStatus;
//	
//	TransmissionBody.GLogXMLElement.Добавить(GLogXMLElement);
//	
//	Возврат TransmissionBody;
//	
//КонецФункции

//&НаСервереБезКонтекста
//Функция ПолучитьShipmentStatus(ФабрикаXDTOTMS, ShipmentNo, StatusCode, EventDate)
//					
//	ShipmentStatus = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "ShipmentStatus");
//	
//	// IntSavedQuery
//	ShipmentStatus.IntSavedQuery = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "IntSavedQuery");
//	ShipmentStatus.IntSavedQuery.IntSavedQueryGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "IntSavedQueryGid");
//	ShipmentStatus.IntSavedQuery.IntSavedQueryGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, "SLB.INT_SHIPMENT_STATUS_GID_3_TEST_SAMPLE");
//		
//	// ShipmentRefnum
//	ShipmentRefnum = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "ShipmentRefnum");
//	ShipmentRefnum.ShipmentRefnumQualifierGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "ShipmentRefnumQualifierGid");
//	ShipmentRefnum.ShipmentRefnumQualifierGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, "GLOG");
//	ShipmentRefnum.ShipmentRefnumValue = "SLB." + ShipmentNo;
//	ShipmentStatus.ShipmentRefnum.Добавить(ShipmentRefnum);
//	
//	// ShipmentStatusType
//	ShipmentStatus.ShipmentStatusType = "Shipment";
//	
//	// StatusLevel
//	ShipmentStatus.StatusLevel = "SHIPMENT";

//	// StatusCodeGid
//	ShipmentStatus.StatusCodeGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "StatusCodeGid");
//	ShipmentStatus.StatusCodeGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, StatusCode);
//		
//	// TimeZoneGid
//	ShipmentStatus.TimeZoneGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "TimeZoneGid");
//	ShipmentStatus.TimeZoneGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, "Europe/Moscow");
//		
//	// EventDt
//	ShipmentStatus.EventDt = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "GLogDateTimeType");
//	ShipmentStatus.EventDt.GLogDate = Формат(EventDate, TMSСервер.ПолучитьФорматДатыTMS());
//	ShipmentStatus.EventDt.TZId = "Europe/Moscow";
//	ShipmentStatus.EventDt.TZOffset = "+04:00";
//	
//	// SSRemarks
//	ShipmentStatus.SSRemarks.Добавить("Automaticaly added by RIET");
//	
//	// SSStop
//	ShipmentStatus.SSStop = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "SSStop");
//	ShipmentStatus.SSStop.SSStopSequenceNum = "1";
//	ShipmentStatus.SSStop.SSLocation = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "SSLocation");
//	ShipmentStatus.SSStop.SSLocation.LocationRefnumQualifierGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "LocationRefnumQualifierGid");
//	ShipmentStatus.SSStop.SSLocation.LocationRefnumQualifierGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, "GLOG");
//	
//	// StatusCodeGid
//	ShipmentStatus.ResponsiblePartyGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "ResponsiblePartyGid");
//	ShipmentStatus.ResponsiblePartyGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, "CARRIER");
// 		
//	Возврат ShipmentStatus;
//	
//КонецФункции
//			 
