
//////////////////////////////////////////////////////////////////////////////////////
// СОБЫТИЯ ФОРМЫ

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	#Если ВебКлиент Тогда
		
	Сообщить("Not available for browser!");
	Отказ = Истина;
	Возврат;	
	
	#Иначе
	
	ВыбратьФайл();
	
	#КонецЕсли
	
КонецПроцедуры


#Если НЕ ВебКлиент Тогда

//////////////////////////////////////////////////////////////////////////////////////
// ВЫБОР ФАЙЛА

&НаКлиенте
Процедура FullPathНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	ВыбратьФайл();
	
КонецПроцедуры

&НаКлиенте
Процедура ВыбратьФайл()
	
	ДиалогВыбораФайла = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	
	ДиалогВыбораФайла.Фильтр						= "XML files|*.xml";
	ДиалогВыбораФайла.ПроверятьСуществованиеФайла	= Истина;
	
	Если ДиалогВыбораФайла.Выбрать() Тогда
		
		FullPath = ДиалогВыбораФайла.ПолноеИмяФайла;
				
	КонецЕсли;
		
КонецПроцедуры


//////////////////////////////////////////////////////////////////////////////////////
// ЗАГРУЗКА

&НаКлиенте
Процедура Load(Команда)
	
	Если НЕ ЗначениеЗаполнено(FullPath) Тогда
		
		ВыбратьФайл();
		
		Если НЕ ЗначениеЗаполнено(FullPath) Тогда
			Возврат;
		КонецЕсли;
		
	КонецЕсли;
	
	// Проверим существование файла и т.д.
	Если НЕ РГСофтКлиентСервер.ФайлДоступенДляЗагрузки(FullPath) Тогда
		Возврат;
	КонецЕсли;
	
	// Поместим файл во временное хранилище
	АдресФайла = Неопределено;
	ПоместитьФайл(АдресФайла, FullPath,, Ложь, УникальныйИдентификатор);
	
	// Разберем файл на сервере и создадим объекты базы
	ЗагрузитьНаСервере(АдресФайла, SendGenericStatusUpdate);		
	
КонецПроцедуры

#КонецЕсли

&НаСервереБезКонтекста
Процедура ЗагрузитьНаСервере(АдресФайла, SendGenericStatusUpdate)
	     			
	TransOrder = ПолучитьTransOrder(АдресФайла);
	
	Если TransOrder = Неопределено Тогда
		Возврат;
	КонецЕсли;
		
	ТекстОшибок = Обработки.PullExportFromTMS.ЗагрузитьTransportRequest(TransOrder);
	
	//Если SendGenericStatusUpdate Тогда
	//	TransmissionAck = Обработки.PullImportFromTMS.PushGenericStatusUpdate(PlannedShipment.Shipment.ShipmentHeader.ShipmentGid.Gid.Xid, ТекстОшибок);	
	//КонецЕсли;
	
	Если ЗначениеЗаполнено(ТекстОшибок) Тогда
		Сообщить(СокрЛП(ТекстОшибок));
	Иначе
		Сообщить("Ok");
	КонецЕсли;
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьTransOrder(АдресФайла)
	
	// Сохраним переданные данные во временный файл
	ДвоичныеДанные = ПолучитьИзВременногоХранилища(АдресФайла);
	ПолноеИмяВременногоФайла = ПолучитьИмяВременногоФайла("xml");
	ДвоичныеДанные.Записать(ПолноеИмяВременногоФайла);
		
	TransOrder = Неопределено;
	
	Попытка	
		TransOrder = ПолучитьTransOrderИзXML(ПолноеИмяВременногоФайла);			
	Исключение
		Сообщить("Failed to load trans order from XML:
			|" + ОписаниеОшибки());
	КонецПопытки;
	
	Попытка
		УдалитьФайлы(ПолноеИмяВременногоФайла);
	Исключение
		Сообщить("Failed to delete temporary file " + ПолноеИмяВременногоФайла + ":
			|" + ОписаниеОшибки());
	КонецПопытки;
	
	Возврат TransOrder;
		
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьTransOrderИзXML(ПутьКФайлу)
	
	//ТипTransOrder = ФабрикаXDTO.Тип(TMSСервер.ПолучитьURIПространстваИменTMSLite(), "TransOrder");
		
	ЧтениеXML = Новый ЧтениеXML;
	ЧтениеXML.ОткрытьФайл(ПутьКФайлу);
	
	ОбъектXDTO = Неопределено;
	Попытка
		//ОбъектXDTO = ФабрикаXDTO.ПрочитатьXML(ЧтениеXML, ТипTransOrder);
		ОбщийОбъектXDTO = ФабрикаXDTO.ПрочитатьXML(ЧтениеXML);
		ОбъектXDTO =  ОбщийОбъектXDTO.TransmissionBody.GLogXMLElement.TransOrder;
	Исключение
		Сообщить("Failed to read xml:
			|" + ОписаниеОшибки());
	КонецПопытки;
	
	Попытка
		ЧтениеXML.Закрыть();
	Исключение
		Сообщить("Failed to close xml:
			|" + ОписаниеОшибки());
	КонецПопытки;
	
	Возврат ОбъектXDTO;
	
КонецФункции

&НаКлиенте
Процедура SaveGenericStatusUpdateInXML(Команда)
	
	Если НЕ ЗначениеЗаполнено(FullPath) Тогда
		
		ВыбратьФайл();
		
		Если НЕ ЗначениеЗаполнено(FullPath) Тогда
			Возврат;
		КонецЕсли;
		
	КонецЕсли;
	
	// Проверим существование файла и т.д.
	Если НЕ РГСофтКлиентСервер.ФайлДоступенДляЗагрузки(FullPath) Тогда
		Возврат;
	КонецЕсли;
	
	// Поместим файл во временное хранилище
	АдресФайла = Неопределено;
	ПоместитьФайл(АдресФайла, FullPath,, Ложь, УникальныйИдентификатор);

	ДиалогВыбораФайла = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Сохранение);	
	ДиалогВыбораФайла.Фильтр = "XML files|*.xml";	
	Если НЕ ДиалогВыбораФайла.Выбрать() Тогда
		Возврат;
	КонецЕсли;	
	PathToXML = ДиалогВыбораФайла.ПолноеИмяФайла;
	
	АдресФайла = SaveAsXMLНаСервере(АдресФайла);
	ДвоичныеДанные = ПолучитьИзВременногоХранилища(АдресФайла);
	ДвоичныеДанные.Записать(PathToXML);
	
КонецПроцедуры	

&НаСервереБезКонтекста
Функция SaveAsXMLНаСервере(АдресФайла)
	
	TransOrder = ПолучитьTransOrder(АдресФайла);
	
	Если TransOrder = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
		
	ТекстОшибок = Обработки.PullExportFromTMS.ЗагрузитьTransportRequest(TransOrder);

	WSСсылка = ПолучитьWSСсылкуДляGenericStatusUpdate();
	ФабрикаXDTOTMS = WSСсылка.ПолучитьWSОпределения().ФабрикаXDTO;
	
	TransmissionHeader = TMSСервер.ПолучитьTransmissionHeader(ФабрикаXDTOTMS);	
	GenericStatusUpdate = ПолучитьGenericStatusUpdate(ФабрикаXDTOTMS, TransOrder.TransOrderHeader.TransOrderGid.Gid.Xid, ТекстОшибок);
	TransmissionBody = TMSСервер.ПолучитьTransmissionBody(ФабрикаXDTOTMS, "GenericStatusUpdate", GenericStatusUpdate);
	Payload = TMSСервер.ПолучитьPayload(ФабрикаXDTOTMS, TransmissionHeader, TransmissionBody);
			
	ИмяВременногоФайла = ПолучитьИмяВременногоФайла("xml");
	
	ЗаписьXML = Новый ЗаписьXML;
	ЗаписьXML.ОткрытьФайл(ИмяВременногоФайла);
	ФабрикаXDTOTMS.ЗаписатьXML(ЗаписьXML, Payload);
	ЗаписьXML.Закрыть();
	
	ДвоичныеДанные = Новый ДвоичныеДанные(ИмяВременногоФайла);
	
	УдалитьФайлы(ИмяВременногоФайла);
	
	Возврат ПоместитьВоВременноеХранилище(ДвоичныеДанные);
		
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьWSСсылкуДляGenericStatusUpdate()
	
	// Возвращает WSСсылку для отправки shipment status update в TMS
	// Для продакшн базы используется одна ссылка, для остальных баз - другая
	
	Если РГСофтСерверПовтИспСеанс.ЭтоProductionБаза() Тогда
		Возврат WSСсылки.TMSPushShipmentStatusProd;
	Иначе
		Возврат WSСсылки.TMSPushShipmentStatusTest;	
	КонецЕсли;
	
КонецФункции

&НаСервереБезКонтекста
Функция СоздатьWSПроксиДляShipmentStatusUpdate(WSСсылка)
	
	// Анализирует WSСсылку и возвращает настроенный WSПрокси, полученной из этой WSСсылки
	
	URIПространстваИмен = "http://xmlns.oracle.com/apps/otm/IntXmlService";
	ИмяСервиса = "IntXmlService";	
	
	Если WSСсылка = WSСсылки.TMSPushShipmentStatusProd Тогда
		ИмяПорта = "IntXml-xbroker_304_DR";
	ИначеЕсли WSСсылка = WSСсылки.TMSPushShipmentStatusTest Тогда
		//ИмяПорта = "IntXml-QaXBroker_2-QaXBroker_2";
		ИмяПорта = "IntXml-QaXBroker_2";
	Иначе
		ВызватьИсключение "Failed to find port for WS reference '" + WSСсылка + "' to push shipment status!";
	КонецЕсли;
	
	Возврат WSСсылка.СоздатьWSПрокси(URIПространстваИмен, ИмяСервиса, ИмяПорта);
	
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьGenericStatusUpdate(ФабрикаXDTOTMS, TransOrderXid, ТекстОшибок)
	
	GenericStatusUpdate = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "GenericStatusUpdate");
	
	GenericStatusUpdate.GenericStatusObjectType = "OB_ORDER_BASE";
	
	GenericStatusUpdate.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, TransOrderXid);
	GenericStatusUpdate.Gid.DomainName = "SLB";
	
	GenericStatusUpdate.TransactionCode = "IU";
	   	
	Если ЗначениеЗаполнено(ТекстОшибок) Тогда 
		
		Remark = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "Remark");
		Remark.TransactionCode = "IU";
		Remark.RemarkSequence = "1";
		Remark.RemarkQualifierGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "RemarkQualifierGid");
		Remark.RemarkQualifierGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, "OB 1C TRANSMISSION");
		Remark.RemarkQualifierGid.Gid.DomainName = "SLB";
		Remark.RemarkText = СокрЛП(ТекстОшибок);
		GenericStatusUpdate.Remark.Добавить(Remark);
		   		
		GenericStatusUpdate.Status.Добавить(ПолучитьStatus(ФабрикаXDTOTMS, "ORDER_BASE 1C TRANSMISSION", "ORDER_BASE 1C TRANSMISSION_INTEGRATION FAILED"));
				
	иначе	
		
		GenericStatusUpdate.Status.Добавить(ПолучитьStatus(ФабрикаXDTOTMS, "ORDER_BASE 1C TRANSMISSION", "ORDER_BASE 1C TRANSMISSION_INTEGRATION SUCCESS"));
		
	КонецЕсли;
	
	
	Возврат GenericStatusUpdate;
	
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьStatus(ФабрикаXDTOTMS, StatusTypeGid, StatusValueGid)
	
	Status = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "Status");
	
	Status.StatusTypeGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "StatusTypeGid");
	Status.StatusTypeGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, StatusTypeGid);
	Status.StatusTypeGid.Gid.DomainName = "SLB";
	
	Status.StatusValueGid = TMSСервер.ПолучитьОбъектXDTOTMS(ФабрикаXDTOTMS, "StatusValueGid");
	Status.StatusValueGid.Gid = TMSСервер.ПолучитьGid(ФабрикаXDTOTMS, StatusValueGid);
	Status.StatusValueGid.Gid.DomainName = "SLB";
	
	Возврат Status;
	
КонецФункции





