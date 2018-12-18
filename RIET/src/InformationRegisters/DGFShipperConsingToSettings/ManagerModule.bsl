
Функция ЕстьСоответствие(Shipper, ConsignTo) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	DGFShipperConsingToSettings.Shipper,
	|	DGFShipperConsingToSettings.ConsignTo
	|ИЗ
	|	РегистрСведений.DGFShipperConsingToSettings КАК DGFShipperConsingToSettings
	|ГДЕ
	|	DGFShipperConsingToSettings.Shipper = &Shipper
	|	И DGFShipperConsingToSettings.ConsignTo = &ConsignTo";
	
	Запрос.УстановитьПараметр("Shipper", Shipper);
	Запрос.УстановитьПараметр("ConsignTo", ConsignTo);
	
	Результат = Запрос.Выполнить();
	
	Возврат НЕ Результат.Пустой(); 
	
КонецФункции