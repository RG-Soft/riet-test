
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(
	Список,
	"Подрядчик",
	ПараметрыСеанса.ТекущийПользователь,
	ВидСравненияКомпоновкиДанных.Равно,
	,
	Ложь,
	РежимОтображенияЭлементаНастройкиКомпоновкиДанных.БыстрыйДоступ);
	
	ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(
	Список,
	"Координатор",
	ПараметрыСеанса.ТекущийПользователь,
	ВидСравненияКомпоновкиДанных.Равно,
	,
	Ложь,
	РежимОтображенияЭлементаНастройкиКомпоновкиДанных.БыстрыйДоступ);
	
	ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(
	Список,
	"СпециалистБиллинга",
	ПараметрыСеанса.ТекущийПользователь,
	ВидСравненияКомпоновкиДанных.Равно,
	,
	Ложь,
	РежимОтображенияЭлементаНастройкиКомпоновкиДанных.БыстрыйДоступ);	
	
	ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(
	Список,
	"ПериодОказанияУслугНачало",
	ПараметрыСеанса.ТекущийПользователь,
	ВидСравненияКомпоновкиДанных.БольшеИлиРавно,
	,
	Ложь,
	РежимОтображенияЭлементаНастройкиКомпоновкиДанных.БыстрыйДоступ);
	
	ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(
	Список,
	"ПериодОказанияУслугОкончание",
	ПараметрыСеанса.ТекущийПользователь,
	ВидСравненияКомпоновкиДанных.МеньшеИлиРавно,
	,
	Ложь,
	РежимОтображенияЭлементаНастройкиКомпоновкиДанных.БыстрыйДоступ);
	
	ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(
	Список,
	"Ссылка.ПометкаУдаления",
	Ложь,
	ВидСравненияКомпоновкиДанных.Равно,
	,
	Истина,
	РежимОтображенияЭлементаНастройкиКомпоновкиДанных.Обычный);
	
КонецПроцедуры
