
////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ОБЩЕГО НАЗНАЧЕНИЯ

&НаСервере
Процедура ОбновитьСписокВариантовDomestic()
	    	
	Запрос = Новый Запрос;
	
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ProjectMobilizationPlanningDomesticСрезПоследних.Variant,
	|	ProjectMobilizationPlanningDomesticСрезПоследних.User,
	|	ProjectMobilizationPlanningDomesticСрезПоследних.ProjectMobilization,
	|	ProjectMobilizationPlanningDomesticСрезПоследних.Период КАК Period
	|ИЗ
	|	РегистрСведений.ProjectMobilizationPlanningDomestic.СрезПоследних(&ТекДата, ) КАК ProjectMobilizationPlanningDomesticСрезПоследних
	|ГДЕ
	|	ИСТИНА
	|	И &УсловиеUser
	|	И &УсловиеProjectMobilization
	|
	|СГРУППИРОВАТЬ ПО
	|	ProjectMobilizationPlanningDomesticСрезПоследних.Variant,
	|	ProjectMobilizationPlanningDomesticСрезПоследних.User,
	|	ProjectMobilizationPlanningDomesticСрезПоследних.ProjectMobilization,
	|	ProjectMobilizationPlanningDomesticСрезПоследних.Период
	|
	|УПОРЯДОЧИТЬ ПО
	|	Period УБЫВ";
	
	Если Не ПоказатьВариантыВсехПользователей Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "&УсловиеUser", "ProjectMobilizationPlanningDomesticСрезПоследних.User = &User");
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ProjectMobilization) Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "&УсловиеProjectMobilization", "ProjectMobilizationPlanningDomesticСрезПоследних.ProjectMobilization = &ProjectMobilization");
		Запрос.УстановитьПараметр("ProjectMobilization", ProjectMobilization);
	КонецЕсли;

	Запрос.УстановитьПараметр("User",						Пользователь);
	Запрос.УстановитьПараметр("УсловиеUser",				Истина);
	Запрос.УстановитьПараметр("УсловиеProjectMobilization",	Истина);
	Запрос.УстановитьПараметр("ТекДата",			    	ТекущаяДата());
	
	Таблица = Запрос.Выполнить().Выгрузить();

	СписокVariant.Загрузить(Таблица);

КонецПроцедуры

&НаСервере
Процедура ОбновитьСписокВариантовInternational()
	
	Запрос = Новый Запрос;
	
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ProjectMobilizationPlanningPerItemСрезПоследних.Variant,
	|	ProjectMobilizationPlanningPerItemСрезПоследних.User,
	|	ProjectMobilizationPlanningPerItemСрезПоследних.ProjectMobilization,
	|	ProjectMobilizationPlanningPerItemСрезПоследних.Период КАК Period
	|ИЗ
	|	РегистрСведений.ProjectMobilizationPlanningPerItem.СрезПоследних(&ТекДата, ) КАК ProjectMobilizationPlanningPerItemСрезПоследних
	|ГДЕ
	|	ИСТИНА
	|	И &УсловиеUser
	|	И &УсловиеProjectMobilization
	|
	|СГРУППИРОВАТЬ ПО
	|	ProjectMobilizationPlanningPerItemСрезПоследних.Период,
	|	ProjectMobilizationPlanningPerItemСрезПоследних.User,
	|	ProjectMobilizationPlanningPerItemСрезПоследних.Variant,
	|	ProjectMobilizationPlanningPerItemСрезПоследних.ProjectMobilization
	|
	|УПОРЯДОЧИТЬ ПО
	|	Period УБЫВ";
	
	Если Не ПоказатьВариантыВсехПользователей Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "&УсловиеUser", "ProjectMobilizationPlanningPerItemСрезПоследних.User = &User");
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ProjectMobilization) Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "&УсловиеProjectMobilization", "ProjectMobilizationPlanningPerItemСрезПоследних.ProjectMobilization = &ProjectMobilization");
		Запрос.УстановитьПараметр("ProjectMobilization", ProjectMobilization);
	КонецЕсли;
	
	Запрос.УстановитьПараметр("User",					    Пользователь);
	Запрос.УстановитьПараметр("УсловиеUser",			    Истина);
	Запрос.УстановитьПараметр("УсловиеProjectMobilization",	Истина);
	Запрос.УстановитьПараметр("ТекДата",			        ТекущаяДата());
	
	Таблица = Запрос.Выполнить().Выгрузить();

	СписокVariant.Загрузить(Таблица);
	
КонецПроцедуры

&НаСервере
Процедура ОбновитьСписокВариантов()
	
	Если DomesticInternational = Перечисления.DomesticInternational.Domestic Тогда
		ОбновитьСписокВариантовDomestic();
	ИначеЕсли DomesticInternational = Перечисления.DomesticInternational.International Тогда
		ОбновитьСписокВариантовInternational();
	КонецЕсли;
		
КонецПроцедуры

&НаКлиенте
Процедура ОбработчикВыбораВарианта()
	
	ТекСтрока = Элементы.СписокVariant.ТекущиеДанные;
	Если ТекСтрока <> Неопределено Тогда
		СтруктураВыбора = Новый Структура("Variant, VariantOwner", ТекСтрока.Variant, ТекСтрока.User);
		ОповеститьОВыборе(СтруктураВыбора);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура УдалитьВариантDomestic(Period, ProjectMobilization, Variant, User)
	
	НаборЗаписей = РегистрыСведений.ProjectMobilizationPlanningDomestic.СоздатьНаборЗаписей();
	
	НаборЗаписей.Отбор.Период.Значение						= Period;
	НаборЗаписей.Отбор.Период.Использование					= Истина;
	НаборЗаписей.Отбор.ProjectMobilization.Значение			= ProjectMobilization;
	НаборЗаписей.Отбор.ProjectMobilization.Использование	= Истина;
	НаборЗаписей.Отбор.Variant.Значение						= Variant;
	НаборЗаписей.Отбор.Variant.Использование				= Истина;
	НаборЗаписей.Отбор.User.Значение						= User;
	НаборЗаписей.Отбор.User.Использование					= Истина;
	
	Попытка
		НаборЗаписей.Записать();
	Исключение
		Сообщить(ОписаниеОшибки());
	КонецПопытки;
	
КонецПроцедуры

&НаСервере
Процедура УдалитьВариантInternational(Period, ProjectMobilization, Variant, User)
	
	НаборЗаписей = РегистрыСведений.ProjectMobilizationPlanningPerItem.СоздатьНаборЗаписей();
	
	НаборЗаписей.Отбор.Период.Значение						= Period;
	НаборЗаписей.Отбор.Период.Использование					= Истина;
	НаборЗаписей.Отбор.ProjectMobilization.Значение			= ProjectMobilization;
	НаборЗаписей.Отбор.ProjectMobilization.Использование	= Истина;
	НаборЗаписей.Отбор.Variant.Значение						= Variant;
	НаборЗаписей.Отбор.Variant.Использование				= Истина;
	НаборЗаписей.Отбор.User.Значение						= User;
	НаборЗаписей.Отбор.User.Использование					= Истина;
	
	Попытка
		НаборЗаписей.Записать();
	Исключение
		Сообщить(ОписаниеОшибки());
	КонецПопытки;
	
КонецПроцедуры

&НаСервере
Процедура УдалитьВариантНаСервере(Period, ProjectMobilization, Variant, User)
	
	Если DomesticInternational = Перечисления.DomesticInternational.Domestic Тогда
		УдалитьВариантDomestic(Period, ProjectMobilization, Variant, User);
	ИначеЕсли DomesticInternational = Перечисления.DomesticInternational.International Тогда
		УдалитьВариантInternational(Period, ProjectMobilization, Variant, User);
	КонецЕсли;
		
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ - ОБРАБОТЧИКИ СОБЫТИЙ ФОРМЫ

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Пользователь = ПараметрыСеанса.ТекущийПользователь;
	
	Параметры.Свойство("DomesticInternational",	DomesticInternational);
	
	Параметры.Свойство("ProjectMobilization",	ProjectMobilization);
	
	ОбновитьСписокВариантов();
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ - ОБРАБОТЧИКИ СОБЫТИЙ КОМАНДНЫХ ПАНЕЛЕЙ

&НаКлиенте
Процедура КомандаОбновитьНажатие(Команда)
	
	ОбновитьСписокВариантов();
	
КонецПроцедуры

&НаКлиенте
Процедура КомандаВыбратьНажатие(Команда)
	
	ОбработчикВыбораВарианта();
	
КонецПроцедуры

&НаКлиенте
Процедура СписокVariantВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	ОбработчикВыбораВарианта();
	
КонецПроцедуры

&НаКлиенте
Процедура КомандаПоказатьВариантыВсехПользователейНажатие(Команда)
	
	ПоказатьВариантыВсехПользователей = Не ПоказатьВариантыВсехПользователей;
	
	Элементы.ФормаКомандаПоказатьВариантыВсехПользователей.Пометка = ПоказатьВариантыВсехПользователей;
	
	ОбновитьСписокВариантов();
	
КонецПроцедуры

&НаКлиенте
Процедура ДействиеВопросаУдалитьВариант(Ответ, ДопПараметры) Экспорт
	
	Если Ответ = КодВозвратаДиалога.Да Тогда
		УдалитьВариантНаСервере(ДопПараметры.Period, ДопПараметры.ProjectMobilization, ДопПараметры.Variant, ДопПараметры.User);
		ОбновитьСписокВариантов();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура КомандаУдалитьВариантНажатие(Команда)
	
	ТекСтрока = Элементы.СписокVariant.ТекущиеДанные;
	Если ТекСтрока <> Неопределено Тогда
		Если ТекСтрока.User = Пользователь Тогда
			
			СтруктураПараметров = Новый Структура("Period, ProjectMobilization, Variant, User");
			ЗаполнитьЗначенияСвойств(СтруктураПараметров, ТекСтрока);
			
			ДействиеВопроса = Новый ОписаниеОповещения("ДействиеВопросаУдалитьВариант", ЭтотОбъект, СтруктураПараметров);
			ТекстВопроса = НСтр("ru = 'Удалить вариант?'; en = 'Delete variant?'");
			ПоказатьВопрос(ДействиеВопроса, ТекстВопроса, РежимДиалогаВопрос.ДаНет);
			
		Иначе
			ТекстПредупрждения = НСтр("ru = 'Можно удалить только свой вариант.'; en = 'You can only delete your own variant.'");
			ПоказатьПредупреждение(, ТекстПредупрждения);
		КонецЕсли;
		
	Иначе
		ТекстПредупрждения = НСтр("ru = 'Выберите строку с варинатом.'; en = 'Select the line with the variant.'");
		ПоказатьПредупреждение(, ТекстПредупрждения);
	КонецЕсли;	
		
КонецПроцедуры

&НаКлиенте
Процедура ProjectMobilizationПриИзменении(Элемент)
	
	ОбновитьСписокВариантов();
	
КонецПроцедуры
