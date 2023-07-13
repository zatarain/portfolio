import type { Station } from './types'
import { MapContainer, TileLayer, Marker, Popup, useMapEvents, useMap } from 'react-leaflet'
import { Icon, LatLng, Marker as LeafletMarker, Map as LeafletMap } from 'leaflet'
import MarkerClusterGroup from 'react-leaflet-cluster'
import { useState, useRef, FormEvent, MutableRefObject } from 'react'
import styles from './index.module.css'
import { Noto_Color_Emoji } from 'next/font/google'

const emoji = Noto_Color_Emoji({ weight: '400', subsets: ['emoji'], preload: false })

interface Properties {
	stationsByCountry: object
}

function flag(country: string) {
	const points = country
		.toUpperCase()
		.split('')
		.map((char) => 127397 + char.charCodeAt(0));
	return String.fromCodePoint(...points);
}

const train = new Icon({
	iconUrl: 'https://cdn-icons-png.flaticon.com/512/1702/1702305.png',
	iconSize: [24, 24],
	iconAnchor: [12, 12],
})

const stadium = new Icon({
	iconUrl: 'https://cdn-icons-png.flaticon.com/512/1540/1540530.png',
	iconSize: [24, 24],
	iconAnchor: [12, 12],
})

const pin = new Icon({
	iconUrl: 'https://cdn-icons-png.flaticon.com/512/2684/2684860.png',
	iconSize: [24, 24],
	iconAnchor: [0, 24],
})

interface MapFormProperties {
	countries: string[],
	map: MutableRefObject<LeafletMap | null>,
}

async function saveMarker() {

}

interface MapFormState {
	station: Station,
	location: LatLng,
}

const MapForm = ({ countries, map }: MapFormProperties) => {
	const [station, setStation] = useState({
		name: '',
		country: 'GB',
		time_zone: 'Europe/London',
		latitude: 51.478,
		longitude: 0,
	} as Station)

	const marker = useRef(null)

	useMapEvents({
		dblclick(event) {
			setStation({
				...station,
				latitude: event.latlng.lat,
				longitude: event.latlng.lng,
			})

			if (marker.current) {
				(marker.current as LeafletMarker).openPopup()
			}
		}
	})

	const submit = async (event: FormEvent) => {
		event.preventDefault()
		await saveMarker()
	}

	return (
		<Marker ref={marker} position={[station.latitude, station.longitude]} icon={pin}>
			<Popup>
				<form id="popup-add-form" className={`${styles.form}`} method="POST" onSubmit={submit}>
					<h3>Add New Marker</h3>
					<label htmlFor="name">Name: </label>
					<input type="text" name="name" required />
					<div className={styles.location}>
						<div>
							<label htmlFor="latitude">Latitude: </label>
							<input type="text" name="latitude" value={station.latitude.toFixed(5)} disabled required />
						</div>
						<div>
							<label htmlFor="longitude">Longitude: </label>
							<input type="text" name="longitude" value={station.longitude.toFixed(5)} disabled required />
						</div>
					</div>
					<label htmlFor="slug">Slug: </label>
					<input type="text" name="slug" />
					<div className={styles['country-time']}>
						<div className={styles.country}>
							<label htmlFor="country">Country: </label>
							<select name="country" className={emoji.className}>
								{countries.map((country) =>
									<option className={emoji.className} key={country} value={country}>{flag(country)}</option>)}
							</select>
						</div>
						<div className={styles.time}>
							<label htmlFor="time_zone">Timezone: </label>
							<input type="text" name="time_zone" />
						</div>
					</div>
					<button type="submit">Save</button>
				</form>
			</Popup>
		</Marker >
	)
}

const GeoFootball = ({ stationsByCountry }: Properties) => {
	const map = useRef(null)

	return (
		<MapContainer
			className={styles.map}
			center={[51.505, 0]}
			zoom={5}
			scrollWheelZoom
			doubleClickZoom={false}
			whenCreated={(self: any) => { map.current = self }}
		>
			<TileLayer
				attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
				url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
			/>
			<MapForm countries={Object.keys(stationsByCountry)} map={map} />
			{Object.entries(stationsByCountry).map(([country, stations]) =>
				<MarkerClusterGroup key={country} chunkedLoading>
					{(stations as Station[]).map((station: Station) =>
						<Marker key={`train-${station.id}`} position={[station.latitude, station.longitude]} icon={train}>
							<Popup key={`train-popup-${station.id}`}>
								<div className={styles.popup}>
									<h3>{station.name}</h3>
									<dl>
										<dt>Country: </dt><dd>{country} <span className={emoji.className}>{flag(country)}</span></dd>
										<dt>Position: </dt><dd>{station.latitude.toFixed(5)}, {station.longitude.toFixed(5)}</dd>
										<dt>Timezone: </dt><dd>{station.time_zone}</dd>
									</dl>
									<p>{station.info_en}</p>
								</div>
							</Popup>
						</Marker>
					)}
				</MarkerClusterGroup>
			)}

		</MapContainer>
	)
}

export default GeoFootball
