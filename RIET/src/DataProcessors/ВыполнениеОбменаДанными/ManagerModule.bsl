#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныеПроцедурыИФункции

// Запускает обмен данными, используется в фоновом задании.
//
// Параметры:
//   ПараметрыВыполнения - Структура - Параметры, необходимые для удаления.
//   АдресХранилища - Строка - Адрес временного хранилища.
//
Процедура ВыполнитьЗапускОбменаДанными(ПараметрыВыполнения, АдресХранилища) Экспорт
	ПараметрыОбмена = ОбменДаннымиСервер.ПараметрыОбмена();
	ЗаполнитьЗначенияСвойств(ПараметрыОбмена, ПараметрыВыполнения,
		"ВидТранспортаСообщенийОбмена,ВыполнятьЗагрузку,ВыполнятьВыгрузку");
	
	ОбменДаннымиСервер.ВыполнитьОбменДаннымиДляУзлаИнформационнойБазы(
		ПараметрыВыполнения.УзелИнформационнойБазы,
		ПараметрыОбмена,
		ПараметрыВыполнения.Отказ);
	
	ПоместитьВоВременноеХранилище(ПараметрыВыполнения, АдресХранилища);
КонецПроцедуры

#КонецОбласти

#КонецЕсли