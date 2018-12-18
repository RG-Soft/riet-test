
Функция ПолучитьПоShipment(Shipment) Экспорт
	
	// Возвращает массив не помеченных на удаление Customs files, привязанных к указанной поставке
	
	Если НЕ ЗначениеЗаполнено(Shipment) Тогда
		Возврат Новый Массив;
	КонецЕсли;
		
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Shipment", Shipment);
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	CustomsFiles.Ссылка
		|ИЗ
		|	Документ.ГТД КАК CustomsFiles
		|ГДЕ
		|	CustomsFiles.Shipment = &Shipment
		|	И НЕ CustomsFiles.ПометкаУдаления";
		
	Возврат Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Ссылка");
	
КонецФункции