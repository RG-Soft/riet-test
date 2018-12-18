
//////////////////////////////////////////////////////////////////////
// Local (Domestic) part of Export 

Процедура PushLocalExportGateInGateOut()  Экспорт 
	                	
	// выгружает в TMS готовые к отправке local export Gate In / Gate Out events
	
	ТаблицаРегистра = РегистрыСведений.LocalExportGateInGateOutEventsQueue.ПолучитьТаблицуLastModifiedBefore(ТекущаяДата() - 3600);
	
	МассивExportRequestNo = РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(ТаблицаРегистра, "ExportRequestNo");
	СтруктураОтбора = Новый Структура("ExportRequestNo");
	
	Для Каждого ExportRequestNo из МассивExportRequestNo Цикл 
		
		// получим Export requests to TMS numbers
		ERNo = СокрЛП(ExportRequestNo);
		
		// получим Domestic shipment numbers из TMS
		СтруктураShipmentNoИStatus = ПолучитьDomesticShipmentNosПоERNo(ERNo);
		
		// при возникновении ошибки - не выгружаем ничего, а переходим к следующей строке Export Request и EventType
		Если СтруктураShipmentNoИStatus = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		
		СтруктураОтбора.ExportRequestNo = ExportRequestNo;
		ТаблицаРегистраCurrentExportRequestNo = ТаблицаРегистра.Скопировать(СтруктураОтбора);
		
		// каждую строку регистра нужно выгрузить и удалить
		Для Каждого СтрокаРегистра Из ТаблицаРегистраCurrentExportRequestNo Цикл
			
			НачатьТранзакцию(РежимУправленияБлокировкойДанных.Управляемый);
			
			//проверим массив статусов
			Для Каждого ShipmentStatus Из СтруктураShipmentNoИStatus.МассивShipmentStatus Цикл
				
				Если ShipmentStatus <> "SECURE RESOURCES_ACCEPTED" 
					И ShipmentStatus <> "SECURE RESOURCES_TENDERED" Тогда
					ОтменитьТранзакцию();
					Продолжить;
				КонецЕсли;
				
			КонецЦикла; 
			
			// удалим запись из регистра
			РегистрыСведений.LocalExportGateInGateOutEventsQueue.УдалитьЗапись(СтрокаРегистра.ExportRequest, СтрокаРегистра.EventType);
			
			// отправим данные в TMS по каждому OR no.
			Для каждого DomesticShipmentNo Из СтруктураShipmentNoИStatus.МассивShipmentNo Цикл
				
				PushGateInGateOutEventToTMS(
				DomesticShipmentNo,
				СтрокаРегистра.EventType,
				СтрокаРегистра.EventDate);
				
			КонецЦикла; 
			
			ЗафиксироватьТранзакцию();
			
		КонецЦикла;
		
	КонецЦикла;

КонецПроцедуры
     
Функция ПолучитьDomesticShipmentNosПоERNo(ERNo)
	
	// Возвращает Domestic shipment numbers по Export request number
	// При этом происходит запрос в TMS, который может привести к ошибке
	// Ошибка фиксируется в журнале регистрации с уровнем Предупреждение и возвращается Неопределено
	// Кроме того, Неопределено возвращается, если TMS вернул пустой массив
	
	Если НЕ ЗначениеЗаполнено(ERNo) Тогда
		ВызватьИсключение "ER no. is empty!";
	КонецЕсли;
	
	DomesticOBNo = TMSСервер.ПолучитьDomesticOBNoПоERNo(ERNo);
		
	Попытка
		DomesticShipmentNosИStatus = Обработки.PullMasterDataFromTMS.ПолучитьСтруктуруShipmentNoИStatus(DomesticOBNo);
	Исключение
		//ЗаписьЖурналаРегистрации(
		//	"Failed to get domestic shipment nos. by OB no.!",
		//	УровеньЖурналаРегистрации.Предупреждение,
		//	Метаданные.Обработки.PushGateInGateOutEventsToTMS,
		//	,
		//	ОписаниеОшибки());			
		Возврат Неопределено;
	КонецПопытки;
	
	Если DomesticShipmentNosИStatus.Количество() = 0 Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Возврат DomesticShipmentNosИStatus;
	
КонецФункции

//////////////////////////////////////////////////////////////////////
// International part of Export

Процедура PushInternationalExportGateInGateOut() Экспорт
	
	// выгружает в TMS готовые к отправке International export Gate In / Gate Out events
	
	ТаблицаРегистра = РегистрыСведений.InternationalExportGateInGateOutEventsQueue.ПолучитьТаблицуLastModifiedBefore(ТекущаяДата() - 3600);  
	
	МассивShipment = РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(ТаблицаРегистра, "Shipment");
	СтруктураОтбора = Новый Структура("Shipment");
	
	Для Каждого Shipment из МассивShipment Цикл 
        		
		// получим Export requests to TMS numbers
		ERNos = Документы.ExportShipment.ПолучитьExportRequestsToTMSNo(Shipment);
	                       	
		// получим Order releases numbers из TMS
		InternationalORNos = ПолучитьInternationalShipmentNosПоERNos(ERNos);
		
		// при возникновении ошибки - не выгружаем ничего, а переходим к следующей строке Shipment и EventType
		Если InternationalORNos = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		
		СтруктураОтбора.Shipment = Shipment;
		ТаблицаРегистраCurrentShipment = ТаблицаРегистра.Скопировать(СтруктураОтбора);
	
		// каждую строку регистра нужно выгрузить и удалить
		Для Каждого СтрокаРегистра Из ТаблицаРегистраCurrentShipment Цикл
			
			НачатьТранзакцию(РежимУправленияБлокировкойДанных.Управляемый);
						
			// удалим запись из регистра
			РегистрыСведений.InternationalExportGateInGateOutEventsQueue.УдалитьЗапись(СтрокаРегистра.Shipment, СтрокаРегистра.EventType);
			
			// отправим данные в TMS по каждому OR no.
			Для Каждого InternationalORNo Из InternationalORNos Цикл
			
				PushGateInGateOutEventToTMS(
					InternationalORNo,
					СтрокаРегистра.EventType,
					СтрокаРегистра.EventDate);
			
			КонецЦикла; 
			        			       				
			ЗафиксироватьТранзакцию();
			
		КонецЦикла;
		
	КонецЦикла;
		
КонецПроцедуры

Функция ПолучитьInternationalShipmentNosПоERNos(ERNos)
	
	// Возвращает Int. Shipment numbers по Export request numbers
	// Если для какого-то ER no. не удалось получить Int. Shipment nos - возвращается Неопределено
	InternationalShipmentNos = Новый Массив;
	Для Каждого ERNo из ERNos Цикл 
		
		СтруктураShipmentNoИStatus = ПолучитьInternationalShipmentNosПоERNo(ERNo);
		Если СтруктураShipmentNoИStatus = Неопределено Тогда
			Возврат Неопределено;
		КонецЕсли;
		
		//проверим массив статусов
		Для Каждого ShipmentStatus Из СтруктураShipmentNoИStatus.МассивShipmentStatus Цикл
			
			Если ShipmentStatus <> "SECURE RESOURCES_ACCEPTED" 
				И ShipmentStatus <> "SECURE RESOURCES_TENDERED" Тогда
				Возврат Неопределено;
			КонецЕсли;
			
		КонецЦикла; 
		
		InternationalShipmentNos = РГСофтКлиентСервер.СложитьМассивы(InternationalShipmentNos, СтруктураShipmentNoИStatus.МассивShipmentNo);	
		
	КонецЦикла;
	
	Возврат InternationalShipmentNos;
	
КонецФункции

Функция ПолучитьInternationalShipmentNosПоERNo(ERNo)
	
	// Возвращает Order release numbers по Export request number
	// При этом происходит запрос в TMS, который может привести к ошибке
	// Ошибка фиксируется в журнале регистрации с уровнем Предупреждение и возвращается Неопределено
	// Кроме того, Неопределено возвращается, если TMS вернул пустой массив
	
	Если НЕ ЗначениеЗаполнено(ERNo) Тогда
		ВызватьИсключение "ER no. is empty!";
	КонецЕсли;
	
	InternationalOBNo = TMSСервер.ПолучитьInternationslOBNoПоERNo(ERNo);
		
	Попытка
		InternationalShipmentNosИStatus = Обработки.PullMasterDataFromTMS.ПолучитьСтруктуруShipmentNoИStatus(InternationalOBNo);
	Исключение
		//ЗаписьЖурналаРегистрации(
		//	"Failed to get Int. shipment nos. by OB no.!",
		//	УровеньЖурналаРегистрации.Предупреждение,
		//	Метаданные.Обработки.PushGateInGateOutEventsToTMS,
		//	,
		//	ОписаниеОшибки());			
		Возврат Неопределено;
	КонецПопытки;
	
	Если InternationalShipmentNosИStatus.Количество() = 0 Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Возврат InternationalShipmentNosИStatus;
	
КонецФункции


////////////////////////////////////////////////////////////////////// 

Процедура PushGateInGateOutEventToTMS(ShipmentNo, EventType, EventDate) 
	
	WSСсылка = Обработки.PushClearanceEventsToTMS.ПолучитьWSСсылку();
	ФабрикаXDTOTMS = WSСсылка.ПолучитьWSОпределения().ФабрикаXDTO;
	
	TransmissionBody = ПолучитьTransmissionBody(ФабрикаXDTOTMS, ShipmentNo, EventType, EventDate);
	
	TransmissionAck = Обработки.PushClearanceEventsToTMS.CallTMS(WSСсылка, ФабрикаXDTOTMS, TransmissionBody);
	           			   		
КонецПроцедуры

Функция ПолучитьTransmissionBody(ФабрикаXDTOTMS, ShipmentNo, EventType, EventDate) 
	  		
	TransmissionBody = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "TransmissionBody");
	
	GLogXMLElement = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "GLogXMLElement");
	
	ShipmentStatus = ПолучитьShipmentStatus(ФабрикаXDTOTMS, ShipmentNo, EventType, EventDate);
	GLogXMLElement.ShipmentStatus = ShipmentStatus;
	
	TransmissionBody.GLogXMLElement.Добавить(GLogXMLElement);
	
	Возврат TransmissionBody;
	
КонецФункции

Функция ПолучитьShipmentStatus(ФабрикаXDTOTMS, ShipmentNo, EventType, EventDate)
	
	ShipmentStatus = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "ShipmentStatus");
		
	// ShipmentRefnum
	ShipmentRefnum = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "ShipmentRefnum");
	ShipmentRefnum.ShipmentRefnumQualifierGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "ShipmentRefnumQualifierGid");
	ShipmentRefnum.ShipmentRefnumQualifierGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, "GLOG");
	ShipmentRefnum.ShipmentRefnumValue = "SLB." + ShipmentNo;
	ShipmentStatus.ShipmentRefnum.Добавить(ShipmentRefnum);
	
	// ShipmentStatusType
	ShipmentStatus.ShipmentStatusType = "Shipment";
	
	// StatusLevel
	ShipmentStatus.StatusLevel = "SHIPMENT";

	// StatusCodeGid
	ShipmentStatus.StatusCodeGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "StatusCodeGid");
	ShipmentStatus.StatusCodeGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, ПолучитьStatusCode(EventType));
		
    // TimeZoneGid
	ShipmentStatus.TimeZoneGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "TimeZoneGid");
	ShipmentStatus.TimeZoneGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, "Europe/Moscow");
		
	// EventDt
	ShipmentStatus.EventDt = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "GLogDateTimeType");
	ShipmentStatus.EventDt.GLogDate = Формат(EventDate, TMSСервер.ПолучитьФорматДатыTMS());
	ShipmentStatus.EventDt.TZId = "Europe/Moscow";
	ShipmentStatus.EventDt.TZOffset = "+04:00";
	
	// SSRemarks
	ShipmentStatus.SSRemarks.Добавить("Automaticaly added by RIET");
	
	// SSStop
	ShipmentStatus.SSStop = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "SSStop");
	ShipmentStatus.SSStop.SSStopSequenceNum = ПолучитьSSStopSequenceNum(EventType);
    ShipmentStatus.SSStop.SSLocation = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "SSLocation");
	ShipmentStatus.SSStop.SSLocation.LocationRefnumQualifierGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "LocationRefnumQualifierGid");
	ShipmentStatus.SSStop.SSLocation.LocationRefnumQualifierGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, "GLOG");
	
	// StatusCodeGid
	ShipmentStatus.ResponsiblePartyGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "ResponsiblePartyGid");
	ShipmentStatus.ResponsiblePartyGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, "CARRIER");
 		
	Возврат ShipmentStatus;
	
КонецФункции

Функция ПолучитьStatusCode(EventType);
	
	Если EventType = Перечисления.GateInGateOutEventsTypes.GateInSource Тогда 
		Возврат "X8";
	ИначеЕсли EventType = Перечисления.GateInGateOutEventsTypes.GateOutSource Тогда 
		Возврат "X6";
	ИначеЕсли EventType = Перечисления.GateInGateOutEventsTypes.GateInDestination Тогда 
		Возврат "X5";
	ИначеЕсли EventType = Перечисления.GateInGateOutEventsTypes.GateOutDestination Тогда 
		Возврат "D1";
	КонецЕсли;	
	
КонецФункции

Функция ПолучитьSSStopSequenceNum(EventType);
	
	Если EventType = Перечисления.GateInGateOutEventsTypes.GateInSource 
		ИЛИ EventType = Перечисления.GateInGateOutEventsTypes.GateOutSource Тогда 
		
		Возврат "1";
		
	ИначеЕсли EventType = Перечисления.GateInGateOutEventsTypes.GateInDestination  
		ИЛИ EventType = Перечисления.GateInGateOutEventsTypes.GateOutDestination Тогда 
		
		Возврат "2";
		
	КонецЕсли;	
	
КонецФункции




         
