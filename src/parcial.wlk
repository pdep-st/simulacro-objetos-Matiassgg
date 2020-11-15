object alegria{
	method efectoAlAsentar(unRecuerdo,unaPersona){
		if(self.puedeAsentarse(unaPersona)){
			unaPersona.agregarPensamientoCentral(unRecuerdo)
			unaPersona.agregarRecuerdoAsentado(unRecuerdo)
		}
	}
	
	method puedeAsentarse(unaPersona) =
		unaPersona.felicidad() > 500
		
	method niegaUn(recuerdo) = not recuerdo.estaAlegre()
	
	method esAlegre() = true
	
}

object tristeza{
	method efectoAlAsentar(unRecuerdo,unaPersona){
		unaPersona.agregarPensamientoCentral(unRecuerdo)
		unaPersona.diminuirFelicidad(10)
		unaPersona.agregarRecuerdoAsentado(unRecuerdo)
	}
	
	method niegaUn(recuerdo) = recuerdo.estaAlegre()
	
	method esAlegre() = false	
}

class EmocionApatica{
	
	method efectoAlAsentar(unRecuerdo,unaPersona){
		// No pasa naranja
	}
	
	method niegaUn(recuerdo) = false
	method esAlegre() = false		
}

object disgusto inherits EmocionApatica{}
object furia inherits EmocionApatica{}
object temor inherits EmocionApatica{}

class Recuerdo{
	const descripcion
	const fecha
	var property emocionActual
	
	// va a venir con la emocion de la persona emocionActual
	method asentar(unaPersona){
		emocionActual.efectoAlAsentar(self,unaPersona)
	}
	
	method esDificil() =
		self.palabras().size() > 10
		
	method palabras() = descripcion.words()
	
	method estaAlegre() = emocionActual.esAlegre()
	
	method contienePalabra(unaPalabra) = 
		self.palabras().contains(unaPalabra)
	
	method diaDeHoy() = tiempo.fechaDeHoy()
	
	method esDeHoy() = fecha == self.diaDeHoy()
	
	method edadDelSuenio() = fecha.year() - self.diaDeHoy().year()
	
	method antiguoA(edad) = self.edadDelSuenio() > edad

}

// Es algo mas auxiliar esto para poder hacer mas comodo
// esDeHoy (el mensaje de los recuerdos)
// edad (el mensaje de una persona)
object tiempo{
	method fechaDeHoy() = new Date()
}

object riley inherits Persona(felicidad = 1000){}

class Persona{
	
	var felicidad
	var emocionDominante
	const recuerdos = []
	const recuerdosAsentados = []
	const pensamientosCentrales = #{}
	const procesosMentales = #{}
	const recuerdosALargoPlazo = []
	var property pensamientoActual
	const nacimiento
	
	
	method vivirEvento(recuerdoDelEvento){
		self.agregarRecuerdo(recuerdoDelEvento)
		self.asentarUn(recuerdoDelEvento)
	}
	
	method agregarRecuerdo(recuerdo){
		recuerdo.emocionActual(emocionDominante)
		recuerdos.add(recuerdo)
	}
	
	method agregarPensamientoCentral(recuerdo){
		pensamientosCentrales.add(recuerdo)
	}
	
	method asentarUn(recuerdo){
		recuerdo.asentar(self)
	}
	
	method diminuirFelicidad(porcentaje){
		const proximaFelicidad = felicidad - (felicidad * porcentaje/100)
		self.felicidad(proximaFelicidad)
	}
	
	method recuerdosRecientesDelDia() = 
		recuerdos.reverse().take(5).reverse()
	
	method pensamientosCentralesDificiles() = 
		self.pensamientosCentrales().filter({recuerdo => recuerdo.esDificil()})
	
	method agregarRecuerdoAsentado(unRecuerdo){
		recuerdosAsentados.add(unRecuerdo)
	}
	
	method felicidad(proximaFelicidad){
		if(proximaFelicidad < 1 || proximaFelicidad > 1000){
			self.error("El nivel resultante no puede quedar por debajo de 1")
		}
		felicidad = proximaFelicidad
	}
	
	method pensamientosCentrales() = pensamientosCentrales
	
	method felicidad() = felicidad
	
	method recuerdosAsentados() = recuerdosAsentados
	
	method recuerdos() = recuerdos
	
	method niega(unRecuerdo) = emocionDominante.niegaUn(unRecuerdo)
	
	method dormir(){
		procesosMentales.forEach({proceso => proceso.desencadenarEfecto(self)})
	}
	
	method noCentralesDelDia() = pensamientosCentrales.filter({recuerdo => recuerdo.esDeHoy()})
	
	method agregarALargoPlazo(recuerdoALargoPlazo){
		recuerdosALargoPlazo.addAll(recuerdoALargoPlazo)		
	}

	method estaDesequilibrada() =
		pensamientosCentrales.contains(recuerdosALargoPlazo.anyOne()) ||
		self.recuerdosDelDiaConMismaEmocion()
	
	method recuerdosDelDiaConMismaEmocion(){
		const recuerdosDeHoy = self.recuerdosDeHoy()
		return recuerdosDeHoy.all({
			recuerdo => recuerdosDeHoy.first().emocionActual() == recuerdo.emocionActual()
		})	
		// Nose si existe una mejor forma de ver que todos los recuerdos
		// tengan la misma emocion
	}
	
	method recuerdosDeHoy() = recuerdos.filter({recuerdo => recuerdo.esDeHoy()})

	method perderPensamientosCentralesEn(cantidad){
		cantidad.times({i => pensamientosCentrales.remove(pensamientosCentrales.first())})
	}
		
	method aumentarFelicidad(cantidad){
		const proximaFelicidad = felicidad + cantidad
		self.felicidad(proximaFelicidad)		
	}
	
	method liberarRecuerdosDelDia(){
		recuerdos.removeAllSuchThat({recuerdo => recuerdo.esDeHoy()})
	}
	
	method rememorar(){
		self.pensamientoActual(self.recuerdoALargoPlazoMasAntiguoAEdad())
	}

	method recuerdoALargoPlazoMasAntiguoAEdad(){
		return recuerdosALargoPlazo.
		filter({recuerdo => recuerdo.antiguoA(self.edad()/2)}).
		anyOne()
	}
	
	method edad() = tiempo.fechaDeHoy().year() - nacimiento.year()
	
	method repeticionesEnMemoriaALargoPlazoDe(recuerdoRepetido) =
		recuerdosALargoPlazo.count({recuerdo => recuerdo == recuerdoRepetido})
	
	method estaTeniendoDejavu() =
		self.repeticionesEnMemoriaALargoPlazoDe(pensamientoActual) > 1
}

class Asentamiento{
	
	method desencadenarEfecto(unaPersona){
		self.criterioRecuerdos(unaPersona).
		forEach({recuerdo => recuerdo.asentar(unaPersona)})
	}
	
	// Sin requisitos , todos los recuerdos se asientan
	method criterioRecuerdos(unaPersona) = 
		unaPersona.recuerdos()
}

class AsentamientoSelectivo inherits Asentamiento{
	const palabraClave
	
	override method criterioRecuerdos(unaPersona) = 
		unaPersona.recuerdos().
		filter({recuerdo => recuerdo.contienePalabra(palabraClave)})
		
}

object profundizacion{
	method desencadenarEfecto(unaPersona){
		const recuerdoALargoPlazo = self.criterioRecuerdos(unaPersona)
		unaPersona.agregarALargoPlazo(recuerdoALargoPlazo)
	}
	
	method criterioRecuerdos(unaPersona) = 
		unaPersona.
		noCentralesDelDia().
		filter({recuerdo => not unaPersona.niega(recuerdo)})
}

object controlHormonal{
	method desencadenarEfecto(unaPersona){
		// Si se cumple el criterio para este proceso
		if(self.criterioRecuerdos(unaPersona)){
			self.producirDesequilibrioHormonal(unaPersona)
		}	
		
	}
	
	method criterioRecuerdos(unaPersona) = unaPersona.estaDesequilibrada()
	
	method producirDesequilibrioHormonal(unaPersona){
		unaPersona.diminuirFelicidad(15)
		unaPersona.perderPensamientosCentralesEn(3)
	}
}

object restauracionCognitiva{
	method desencadenarEfecto(unaPersona){
		unaPersona.aumentarFelicidad(100)
	}
}

object liberacionDeRecuerdosDelDia{
	
	method desencadenarEfecto(unaPersona){
		unaPersona.liberarRecuerdosDelDia()
	}
}

class EmocionCompuesta{
	const emociones = []
	
	method efectoAlAsentar(unRecuerdo,unaPersona){
		emociones.forEach({emocion => emocion.efectoAlAsentar(unRecuerdo,unaPersona)})
	}
		
	method niegaUn(recuerdo) = 
		emociones.all({emocion => emocion.niegaUn(recuerdo)})
	
	method esAlegre() = 
		emociones.any({emocion => emocion.esAlegre()})
}

