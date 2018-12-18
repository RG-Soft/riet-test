
Функция ПолучитьItemsOfTemporaryImpExpTransactions(TemporaryImpExpTransactions) Экспорт
	
	Если НЕ ЗначениеЗаполнено(TemporaryImpExpTransactions) Тогда
		Возврат Новый Массив;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("TemporaryImpExpTransactions", TemporaryImpExpTransactions);
	
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	TemporaryImpExpTransactionsItems.Item
		|ИЗ
		|	Документ.TemporaryImpExpTransactions.Items КАК TemporaryImpExpTransactionsItems
		|ГДЕ
		|	TemporaryImpExpTransactionsItems.Ссылка = &TemporaryImpExpTransactions";
	
	Возврат Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Item");
	
КонецФункции
