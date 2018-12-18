
Функция ПроверитьОстатокПоПарселю(Парсель, TR, TR_Adj) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	ParcelsOfTransportRequestsWithoutShipmentОстаткиИОбороты.NumOfParcelsКонечныйОстаток КАК NumOfParcelsОстаток
	|ИЗ
	|	РегистрНакопления.ParcelsOfTransportRequestsWithoutShipment.ОстаткиИОбороты(
	|			,
	|			,
	|			Регистратор,
	|			,
	|			Parcel = &Парсель
	|				И TransportRequest = &TransportRequest) КАК ParcelsOfTransportRequestsWithoutShipmentОстаткиИОбороты
	|ГДЕ
	|	ParcelsOfTransportRequestsWithoutShipmentОстаткиИОбороты.Регистратор <> &TR_Adj
	|
	|УПОРЯДОЧИТЬ ПО
	|	ParcelsOfTransportRequestsWithoutShipmentОстаткиИОбороты.Регистратор.Дата УБЫВ";
	Запрос.УстановитьПараметр("Парсель", Парсель);
	Запрос.УстановитьПараметр("TransportRequest", TR);
	Запрос.УстановитьПараметр("TR_Adj", TR_Adj);
	
	Результат = Запрос.Выполнить();
	Если Результат.Пустой() Тогда
		Количество = 0;
	Иначе
		Выборка = Результат.Выбрать();
		Выборка.Следующий();
		Количество = Выборка.NumOfParcelsОстаток;
	КонецЕсли;
	
	Возврат Количество;
	
КонецФункции

Функция ПолучитьОстатки(TransportRequest, ДатаДока) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	ParcelsOfTransportRequestsWithoutShipmentОстатки.Parcel,
	|	ParcelsOfTransportRequestsWithoutShipmentОстатки.NumOfParcelsОстаток КАК NumOfParcels
	|ИЗ
	|	РегистрНакопления.ParcelsOfTransportRequestsWithoutShipment.Остатки(&ДатаДока, TransportRequest = &TR) КАК ParcelsOfTransportRequestsWithoutShipmentОстатки";
	Запрос.УстановитьПараметр("TR", TransportRequest);
	Запрос.УстановитьПараметр("ДатаДока", ДатаДока);
	
	Возврат Запрос;
	
КонецФункции