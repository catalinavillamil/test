#------------------------------------------------------------------------
#            PAQUETES NECESARIOS (lectura datos)
#------------------------------------------------------------------------

library(tidyr)

#------------------------------------------------------------------------
#            PAQUETES NECESARIOS (Paquete)
#------------------------------------------------------------------------

library(fda)
library(gstat)
library(sp)
library(gridExtra)
library(GenSA)

#------------------------------------------------------------------------
#            PAQUETES NECESARIOS (Paquete)
#------------------------------------------------------------------------

library(ggplot2)

#------------------------------------------------------------------------
#              FUNCIONES NECESARIAS
#------------------------------------------------------------------------

namedi=function(X){
     n=dim(X)
     for(i in 4:n[2]){
          X[is.na(X[,i]),i]=median(X[,i],na.rm = T)
     }
     return(X)
}

#------------------------------------------------------------------------
#              DATOS
#------------------------------------------------------------------------

cont2017=read.csv("~/Docs/Estadistica/Trabajo de grado/Datos Arreglados/cont2017.csv")

##PM10
PM1017=cont2017[cont2017$id_parameter=="PM10",]
a=rep(1:8760,each=24)
PM1017[,1]=a
PM1017=spread(PM1017,id_station,value)
PM1017=namedi(PM1017)
PM1017=PM1017[,-c(19,25)]
PM1017=PM1017[,-c(11,14,17)]
PM1017=PM1017[,-7]
MPM1017=as.matrix(PM1017[,-c(1:3)])
MPM1017=MPM1017[-c(1:2299,2601:8760),]
datos=read.table("C:/Users/Catalina Villamil/Downloads/Mexico/Mexico/coordenadasmexico.txt",head=T,dec=",",row.names=1)
coordenadas=datos[c(1,3,4,5,8,11,16,17,18,24,26,31,34,37,38,39,42,43),c(1,2)]
#MPM1017=MPM1017[,-c(1,2,6,7,8,10,13,16,17,18)]
#coordenadas=coordenadas[-c(1,2,6,7,8,10,13,16,17,18),]
MPM1017=MPM1017[,-c(1,6,7)]
coordenadas=coordenadas[-c(1,6,7),]
coordenadas1=coordenadas

#NO2
NO217=cont2017[cont2017$id_parameter=="NO2",]
a2=rep(1:8760,each=29)
NO217[,1]=a2
NO217=spread(NO217,id_station,value)
NO217=namedi(NO217)
NO217=NO217[,-c(9,17)]
NO217=NO217[,-c(6,7,8,14,15,17,19,21,24,25,27,28)]
MNO217=as.matrix(NO217[,-c(1:3)])
MNO217=MNO217[-c(1:2299,2601:8760),]
MNO217=MNO217[,c(1,2,4,6,7,8,11,13,14,15)]
coordenadas2=datos[c(1,3,10,11,12,16,17,24,27,30,34,32,39,42,43),c(1,2)]
coordenadas2=coordenadas2[c(1,2,4,6,7,8,11,13,14,15),]


#------------------------------------------------------------------------#
#            EJEMPLO
#------------------------------------------------------------------------#

##OBJETO SPATFD
ds=SpatFD(MPM1017,coordenadas,nbasis = 60,lambda=0.01,nharm=3)
ds=SpatFD(MNO217,coordenadas2,nbasis = 60,lambda = 0.01,nharm=2,add=ds)

#ds=SpatFD(MPM1017,coordenadas,nbasis = 60,lambda=0.01,nharm=2)
#ds=SpatFD(MNO217,coordenadas2,nbasis = 60,lambda = 0.01,nharm=1,add=ds)

#ds1=SpatFD(MNO217,coordenadas2,nbasis = 60,lambda=0.01,nharm=3)
#ds1=SpatFD(MPM1017,coordenadas,nbasis = 60,lambda = 0.01,nharm=2,add=ds1)
#model=list(vgm(1000,'Gau',11000),vgm(1000,'Gau',11000),vgm(1000,'Gau',11000),vgm(1000,'Gau',11000))
model=vgm(1000,'Gau',10000)
#model=vgm(1,'Exp',20000)

X=ds
newcoords=datos[,1:2]

fk=FKSK(ds,newcoords,model)
fc=FKCK(ds,newcoords,model)
cok=FCOK(ds,newcoords,model)

COS=data.frame(c(487382,491853),c(2135184,2139368))
colnames(COS)=c("X","Y")
fixcoords=coordenadas
movcoords=newcoords[c(1,33,40),]
modelo= cok$model$model
.varfcok(X,modelo,fixcoords,movcoords,COS[1,])
xbound=c(min(coordenadas[,1]),max(coordenadas[,1]))
ybound=c(min(coordenadas[,2]),max(coordenadas[,2]))
OSFCOK(X,modelo,fixcoords,movcoords,COS,xbound,ybound)