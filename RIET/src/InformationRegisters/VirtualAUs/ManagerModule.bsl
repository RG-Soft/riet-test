#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

Функция ПолучитьVirtualAUs() Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	VirtualAUs.AU
		|ИЗ
		|	РегистрСведений.VirtualAUs КАК VirtualAUs";

	РезультатЗапроса = Запрос.Выполнить();

	Возврат РезультатЗапроса.Выгрузить().ВыгрузитьКолонку("AU");

КонецФункции

#КонецЕсли