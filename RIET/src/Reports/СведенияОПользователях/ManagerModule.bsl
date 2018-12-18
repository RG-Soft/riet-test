#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныйПрограммныйИнтерфейс

// Настройки размещения в панели отчетов.
//
// Параметры:
//   Настройки - Коллекция - Используется для описания настроек отчетов и вариантов
//       см. описание к ВариантыОтчетов.ДеревоНастроекВариантовОтчетовКонфигурации()
//   НастройкиОтчета - СтрокаДереваЗначений - Настройки размещения всех вариантов отчета.
//       см. "Реквизиты для изменения" функции ВариантыОтчетов.ДеревоНастроекВариантовОтчетовКонфигурации().
//
// Описание:
//   См. ВариантыОтчетовПереопределяемый.НастроитьВариантыОтчетов().
//
// Вспомогательные методы:
//   НастройкиВарианта = ВариантыОтчетов.ОписаниеВарианта(Настройки, НастройкиОтчета, "<ИмяВарианта>");
//   ВариантыОтчетов.УстановитьРежимВыводаВПанеляхОтчетов(Настройки, НастройкиОтчета, Истина/Ложь); // Отчет поддерживает только этот режим.
//
Процедура НастроитьВариантыОтчета(Настройки, НастройкиОтчета) Экспорт
	МодульВариантыОтчетов = ОбщегоНазначения.ОбщийМодуль("ВариантыОтчетов");
	
	НастройкиВарианта = МодульВариантыОтчетов.ОписаниеВарианта(Настройки, НастройкиОтчета, "СведенияОПользователяхИВнешнихПользователях");
	НастройкиВарианта.Описание = 
		НСтр("ru = 'Выводит подробные сведения о всех пользователях,
		|включая настройки для входа (если указаны).'");
	НастройкиВарианта.ФункциональныеОпции.Добавить("ИспользоватьВнешнихПользователей");
	
	НастройкиВарианта = МодульВариантыОтчетов.ОписаниеВарианта(Настройки, НастройкиОтчета, "СведенияОПользователях");
	НастройкиВарианта.Описание = 
		НСтр("ru = 'Выводит подробные сведения о пользователях,
		|включая настройки для входа (если указаны).'");
	
	НастройкиВарианта = МодульВариантыОтчетов.ОписаниеВарианта(Настройки, НастройкиОтчета, "СведенияОВнешнихПользователях");
	НастройкиВарианта.Описание = 
		НСтр("ru = 'Выводит подробные сведения о внешних пользователях,
		|включая настройки для входа (если указаны).'");
	НастройкиВарианта.ФункциональныеОпции.Добавить("ИспользоватьВнешнихПользователей");
КонецПроцедуры

#КонецОбласти

#КонецЕсли

#Область ОбработчикиСобытий

Процедура ОбработкаПолученияФормы(ВидФормы, Параметры, ВыбраннаяФорма, ДополнительнаяИнформация, СтандартнаяОбработка)
	
	Если Не Параметры.Свойство("КлючВарианта") Тогда
		СтандартнаяОбработка = Ложь;
		Параметры.Вставить("КлючВарианта", "СведенияОПользователяхИВнешнихПользователях");
		ВыбраннаяФорма = "Отчет.СведенияОПользователях.Форма";
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти
