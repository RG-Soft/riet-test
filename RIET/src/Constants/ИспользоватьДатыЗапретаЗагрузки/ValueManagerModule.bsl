#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

Процедура ПриЗаписи(Отказ)
	
	//Закомментировала Федотова Л., РГ-Софт, 10.05.16, вопрос SLI-0006458
	//Если Не ДополнительныеСвойства.Свойство("ПропуститьОбновлениеВерсииДатЗапретаИзменения") Тогда
	//	ДатыЗапретаИзмененияСлужебный.ОбновитьВерсиюДатЗапретаИзменения();
	//КонецЕсли;
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли
