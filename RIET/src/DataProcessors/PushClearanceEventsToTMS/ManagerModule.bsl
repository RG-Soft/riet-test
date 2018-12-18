
Процедура PushReadyImport() Экспорт 
	
	// выгружает в TMS гтовые к отправке Import clearance events
	
	// получим данные, готовые к выгрузке
	ТаблицаРегистра = РегистрыСведений.ImportClearanceEventsQueue.ПолучитьТаблицуLastModifiedBefore(ТекущаяДата() - 3600);
		
	Import = Перечисления.ИмпортЭкспорт.Import;
	
	МассивShipment = РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(ТаблицаРегистра, "Shipment");
	СтруктураОтбора = Новый Структура("Shipment");
	
	Для Каждого Shipment из МассивShipment Цикл 
		
		ORNos = Документы.Поставка.ПолучитьInvoicesToTMSNo(Shipment);

		Если ORNos = Неопределено Тогда 
			Продолжить;
		КонецЕсли;
		
		СтруктураОтбора.Shipment = Shipment;
		ТаблицаРегистраCurrentShipment = ТаблицаРегистра.Скопировать(СтруктураОтбора);
				
		// выгрузим каждую строку регистра
		Для Каждого СтрокаРегистра Из ТаблицаРегистраCurrentShipment Цикл
							
			НачатьТранзакцию(РежимУправленияБлокировкойДанных.Управляемый);
		
			// удалим запись из регистра
			РегистрыСведений.ImportClearanceEventsQueue.УдалитьЗапись(СтрокаРегистра.Shipment, СтрокаРегистра.EventType);
				
			// отправим данные в TMS
			
			Для Каждого ORNo Из ORNos Цикл
				
				PushClearanceEventToTMS(
					Import,
					СокрЛП(ORNo),
					СтрокаРегистра.EventType,
					СтрокаРегистра.EventDate,
					СокрЛП(СтрокаРегистра.Alias));
					
			КонецЦикла;
			
			ЗафиксироватьТранзакцию();
			
		КонецЦикла;
	
	КонецЦикла;
		        	        	
КонецПроцедуры

Процедура PushReadyExport() Экспорт 
	
	// выгружает в TMS готовые к отправке Export clearance events
	
	ТаблицаРегистра = РегистрыСведений.ExportClearanceEventsQueue.ПолучитьТаблицуLastModifiedBefore(ТекущаяДата() - 3600);
				
	ЗначениеExport = Перечисления.ИмпортЭкспорт.Export;
	
	МассивShipment = РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(ТаблицаРегистра, "Shipment");
	СтруктураОтбора = Новый Структура("Shipment");
	
	Для Каждого Shipment из МассивShipment Цикл 
		
		// получим Export requests to TMS numbers
		ERNos = Документы.ExportShipment.ПолучитьExportRequestsToTMSNo(Shipment);
		
		// получим Order releases numbers из TMS
		InternationalORNos = ПолучитьInternationalORNosПоERNos(ERNos);
		
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
			РегистрыСведений.ExportClearanceEventsQueue.УдалитьЗапись(СтрокаРегистра.Shipment, СтрокаРегистра.EventType);
			
			// отправим данные в TMS по каждому OR no.
			Для Каждого InternationalORNo Из InternationalORNos Цикл
					
				PushClearanceEventToTMS(
					ЗначениеExport,
					InternationalORNo,
					СтрокаРегистра.EventType,
					СтрокаРегистра.EventDate,
					СокрЛП(СтрокаРегистра.Alias));
				
			КонецЦикла;
			
			ЗафиксироватьТранзакцию();
			
		КонецЦикла;
	
	КонецЦикла;
	
КонецПроцедуры

Функция ПолучитьInternationalORNosПоERNos(ERNos)
	
	// Возвращает Order release numbers по Export request numbers
	// Если для какого-то ER no. не удалось получить OR nos - возвращается Неопределено
	InternationalORNos = Новый Массив;
	Для Каждого ERNo из ERNos Цикл 
		
		ERInternationalORNos = ПолучитьInternationalORNosПоERNo(ERNo);
		Если ERInternationalORNos = Неопределено Тогда
			Возврат Неопределено;
		КонецЕсли;
		
		InternationalORNos = РГСофтКлиентСервер.СложитьМассивы(InternationalORNos, ERInternationalORNos);	
		
	КонецЦикла;
	
	Возврат InternationalORNos;
	
КонецФункции

Функция ПолучитьInternationalORNosПоERNo(ERNo)
	
	// Возвращает Order release numbers по Export request number
	// При этом происходит запрос в TMS, который может привести к ошибке
	// Ошибка фиксируется в журнале регистрации с уровнем Предупреждение и возвращается Неопределено
	// Кроме того, Неопределено возвращается, если TMS вернул пустой массив
	
	Если НЕ ЗначениеЗаполнено(ERNo) Тогда
		ВызватьИсключение "ER no. is empty!";
	КонецЕсли;
	
	InternationalOBNo = TMSСервер.ПолучитьInternationslOBNoПоERNo(ERNo);
		
	Попытка
		InternationalORNos = Обработки.PullMasterDataFromTMS.ПолучитьReleaseNo(InternationalOBNo);
	Исключение
		//ЗаписьЖурналаРегистрации(
		//	"Failed to get OR nos. by OB no.!",
		//	УровеньЖурналаРегистрации.Предупреждение,
		//	Метаданные.Обработки.PushClearanceEventsToTMS,
		//	,
		//	ОписаниеОшибки());			
		Возврат Неопределено;
	КонецПопытки;
	
	Если InternationalORNos.Количество() = 0 Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Возврат InternationalORNos;
	
КонецФункции

Процедура PushClearanceEventToTMS(ImportExport, ReleaseNo, EventType, EventDate, Alias) 
	
	WSСсылка = ПолучитьWSСсылку();
	ФабрикаXDTOTMS = WSСсылка.ПолучитьWSОпределения().ФабрикаXDTO;
	
	TransmissionBody = ПолучитьTransmissionBody(ФабрикаXDTOTMS, ImportExport, ReleaseNo, EventType, EventDate, Alias);
	
	TransmissionAck = CallTMS(WSСсылка, ФабрикаXDTOTMS, TransmissionBody);
	           			   		
КонецПроцедуры

Функция ПолучитьTransmissionBody(ФабрикаXDTOTMS, ImportExport, ReleaseNo, EventType, EventDate, Alias)  Экспорт
		
	TransmissionBody = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "TransmissionBody");
	
	GLogXMLElement = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "GLogXMLElement");
	
	TransOrderStatus = ПолучитьTransOrderStatus(ФабрикаXDTOTMS, ImportExport, ReleaseNo, EventType, EventDate, Alias);
	GLogXMLElement.TransOrderStatus = TransOrderStatus;
	
	TransmissionBody.GLogXMLElement.Добавить(GLogXMLElement);
	
	Возврат TransmissionBody;
	
КонецФункции

Функция ПолучитьTransOrderStatus(ФабрикаXDTOTMS, ImportExport, ReleaseNo, EventType, EventDate, Alias)
	
	Если ImportExport = Перечисления.ИмпортЭкспорт.Import Тогда 
		StatusGroupXid = "IMPORT CUSTOMS";
		StatusCodeXid = ?(EventType = Перечисления.ClearanceEventsTypes.InCustoms, "IC4", "IC5");
	Иначе
		StatusGroupXid = "EXPORT CUSTOMS";
		StatusCodeXid = ?(EventType = Перечисления.ClearanceEventsTypes.InCustoms, "EC4", "EC5");
	КонецЕсли;
	
	TransOrderStatus = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "TransOrderStatus");
	
	// No
	TransOrderStatus.ReleaseGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "ReleaseGid");
	TransOrderStatus.ReleaseGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, СокрЛП(ReleaseNo));
	TransOrderStatus.ReleaseGid.Gid.DomainName = "SLB";
	
	// Description
	TransOrderStatus.Description = ?(EventType = Перечисления.ClearanceEventsTypes.InCustoms, "IN CUSTOMS", "CLEAR");
	
	// Status Level
	TransOrderStatus.StatusLevel = "ORDER";	
	
	//Status Code
	TransOrderStatus.StatusCodeGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "StatusCodeGid");
	TransOrderStatus.StatusCodeGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, StatusCodeXid);
	TransOrderStatus.StatusCodeGid.Gid.DomainName = "SLB";

	//Status Code
	TransOrderStatus.TimeZoneGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "TimeZoneGid");
	TransOrderStatus.TimeZoneGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, "Europe/Moscow");
	
	//Event Dt
	TransOrderStatus.EventDt = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "GLogDateTimeType");
	TransOrderStatus.EventDt.GLogDate = Формат(EventDate, TMSСервер.ПолучитьФорматДатыTMS());
	TransOrderStatus.EventDt.TZId = "Europe/Moscow";
	TransOrderStatus.EventDt.TZOffset = "+04:00";
	
	//Status Group
	TransOrderStatus.StatusGroup = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "StatusGroup");
	TransOrderStatus.StatusGroup.StatusGroupGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "StatusGroupGid");
	TransOrderStatus.StatusGroup.StatusGroupGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, StatusGroupXid);
	TransOrderStatus.StatusGroup.StatusGroupGid.Gid.DomainName = "SLB";
	
	//Reason Group
	TransOrderStatus.ReasonGroup = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "ReasonGroup");
	TransOrderStatus.ReasonGroup.ReasonGroupGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "ReasonGroupGid");
	TransOrderStatus.ReasonGroup.ReasonGroupGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, "CUSTOMS REASONS");
	TransOrderStatus.ReasonGroup.ReasonGroupGid.Gid.DomainName = "SLB";

	//Responsible Party
	TransOrderStatus.ResponsiblePartyGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "ResponsiblePartyGid");
	TransOrderStatus.ResponsiblePartyGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, "CUSTOM CLEARANCE");
	TransOrderStatus.ResponsiblePartyGid.Gid.DomainName = "SLB";

	// Reporting User
	TransOrderStatus.ReportingUser = "SLB." + ВРег(Alias);
	
	Возврат TransOrderStatus;
	
КонецФункции

Функция CallTMS(WSСсылка, ФабрикаXDTOTMS, TransmissionBody) Экспорт
	
	// Пушает данные в TMS
	// Возвращает ответ - TransmissionAck
	
	TransmissionHeader = TMSСервер.ПолучитьTransmissionHeader(ФабрикаXDTOTMS, , "SIMS");
	
	Payload = TMSСервер.ПолучитьPayload(ФабрикаXDTOTMS, TransmissionHeader, TransmissionBody);
	
	WSПрокси = СоздатьWSПрокси(WSСсылка);
		
	Возврат WSПрокси.process(Payload);
	
КонецФункции

Функция ПолучитьWSСсылку() Экспорт
	
	// Возвращает WSСсылку для отправки clearance events в TMS
	// Для продакшн базы используется одна ссылка, для остальных баз - другая
	
	Если РГСофтСерверПовтИспСеанс.ЭтоProductionБаза() Тогда
		Возврат WSСсылки.TMSPushClearanceEventProd;	
	Иначе
		Возврат WSСсылки.TMSPushClearanceEventTest;	
	КонецЕсли;
	
КонецФункции

Функция СоздатьWSПрокси(WSСсылка)
	
	// Анализирует WSСсылку и возвращает настроенный WSПрокси, полученной из этой WSСсылки
	
	URIПространстваИмен = "http://xmlns.oracle.com/apps/otm/IntXmlService";
	ИмяСервиса = "IntXmlService";	
	
	Если WSСсылка = WSСсылки.TMSPushClearanceEventProd Тогда
		ИмяПорта = "IntXml-xbroker_304_DR";
	ИначеЕсли WSСсылка = WSСсылки.TMSPushClearanceEventTest Тогда
		ИмяПорта = "IntXml-QaXBroker_2";
	Иначе
		ВызватьИсключение "Failed to find port for WS reference '" + WSСсылка + "' to push clearance events!";
	КонецЕсли;
	
	Возврат WSСсылка.СоздатьWSПрокси(URIПространстваИмен, ИмяСервиса, ИмяПорта);
	
КонецФункции

