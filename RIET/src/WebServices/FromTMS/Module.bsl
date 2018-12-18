
Функция PushPlannedShipment(Transmission) Экспорт
	
	НачатьТранзакцию(РежимУправленияБлокировкойДанных.Управляемый);
	
	// Перехватим ошибки и залоггируем (по-умолчанию платформа не логгирует исключения в веб-сервисах)
	Попытка
	
		УстановитьПривилегированныйРежим(Истина);
					
		PullImportFromTMS = Обработки.PullImportFromTMS;
		PlannedShipment = Transmission.TransmissionBody.GLogXMLElement.PlannedShipment;
		
		// Загрузим PlannedShipment
		ТекстОшибок = PullImportFromTMS.ЗагрузитьPlannedShipment(PlannedShipment);
		
		// Отправим отчет о загрузке
		PullImportFromTMS.PushGenericStatusUpdate(PlannedShipment.Shipment.ShipmentHeader.ShipmentGid.Gid.Xid, ТекстОшибок);
		
		// Отправим ответ (уже не используется, так как TMS не может принимать наши ответы
		TransmissionAck = PullImportFromTMS.ПолучитьTransmissionAck(Transmission.TransmissionHeader, ТекстОшибок);
			
		ЗафиксироватьТранзакцию();
		
		// Залоггируем
		ЗаписьЖурналаРегистрации(
			"Received planned shipment from TMS",
			УровеньЖурналаРегистрации.Информация,
			Метаданные.WebСервисы.FromTMS,
			,
			"Shipment no.: " + PlannedShipment.Shipment.ShipmentHeader.ShipmentGid.Gid.Xid + "
			|Errors:
			|" + ТекстОшибок);
		
		Возврат TransmissionAck;
	
	Исключение
		
		ОтменитьТранзакцию();
		ЗаписьЖурналаРегистрации(
			"Error processing planned shipment from TMS",
			УровеньЖурналаРегистрации.Ошибка,
			Метаданные.WebСервисы.FromTMS,
			,
			"Shipment no.: " + PlannedShipment.Shipment.ShipmentHeader.ShipmentGid.Gid.Xid + "
			|" + ОписаниеОшибки());
			
	КонецПопытки;
	
КонецФункции

Функция PushTransOrder(Transmission) Экспорт
	
	НачатьТранзакцию(РежимУправленияБлокировкойДанных.Управляемый);
	
	// Перехватим ошибки и залоггируем (по-умолчанию платформа не логгирует исключения в веб-сервисах)
	Попытка
	
		УстановитьПривилегированныйРежим(Истина);
					
		PullExportFromTMS = Обработки.PullExportFromTMS;
		TransOrder = Transmission.TransmissionBody.GLogXMLElement.TransOrder;
		
		// Загрузим TransportRequest
		ТекстОшибок = PullExportFromTMS.ЗагрузитьTransportRequest(TransOrder);
		
		TransOrderID = TransOrder.TransOrderHeader.TransOrderGid.Gid.Xid;
		
		// Отправим отчет о загрузке
		PullExportFromTMS.PushGenericStatusUpdate(TransOrderID, ТекстОшибок);
		
		// Отправим ответ (уже не используется, так как TMS не может принимать наши ответы
		TransmissionAck = PullExportFromTMS.ПолучитьTransmissionAck(Transmission.TransmissionHeader, ТекстОшибок);
		
		ЗафиксироватьТранзакцию();
		
		// Залоггируем
		ЗаписьЖурналаРегистрации(
			"Received TransOrder from TMS",
			УровеньЖурналаРегистрации.Информация,
			Метаданные.WebСервисы.FromTMS,
			,
			"TransOrder no.: " + TransOrderID + "
			|Errors:
			|" + ТекстОшибок);
		
		Возврат TransmissionAck;
	
	Исключение
		
		ОтменитьТранзакцию();
		ЗаписьЖурналаРегистрации(
			"Error processing TransOrder from TMS",
			УровеньЖурналаРегистрации.Ошибка,
			Метаданные.WebСервисы.FromTMS,
			,
			"TransOrder no.: " + TransOrderID + "
			|" + ОписаниеОшибки());
			
	КонецПопытки;
	
КонецФункции

